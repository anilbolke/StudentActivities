import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Random;

/**
 * ClickerBridge - runs on the teacher's PC next to the clicker USB receiver.
 *
 * Flow:
 *   1. Polls  GET  /api/liveState?examId=N  to know which question is on screen
 *   2. Receives keypad events (clickerId + key A-D)
 *   3. Posts  POST /api/answer  with clickerId + current questionId
 *
 * Run (simulator mode, no hardware needed):
 *   javac ClickerBridge.java
 *   java ClickerBridge http://localhost:8080/StudentActivities 19
 *
 * Console commands in simulator mode:
 *   K05 A        -> clicker K05 pressed A
 *   auto         -> all 30 dummy clickers (K01-K30) answer the current question
 *   state        -> show current live state
 *   quit         -> exit
 *
 * When real hardware arrives, implement ReceiverListener for the vendor's
 * serial/HID protocol and call bridge.onKey(clickerId, key) - nothing else changes.
 */
public class ClickerBridge {

    private final String serverBase;
    private final int examId;

    // live state, refreshed by the poller thread
    private volatile int currentQuestionId = -1;
    private volatile int questionNumber = -1;
    private volatile int totalQuestions = -1;
    private volatile String status = "UNKNOWN";

    public ClickerBridge(String serverBase, int examId) {
        this.serverBase = serverBase;
        this.examId = examId;
    }

    public static void main(String[] args) throws Exception {
        String server = args.length > 0 ? args[0] : "http://localhost:8080/StudentActivities";
        int examId = args.length > 1 ? Integer.parseInt(args[1]) : promptExamId();

        ClickerBridge bridge = new ClickerBridge(server, examId);
        bridge.startPolling();

        System.out.println("==============================================");
        System.out.println("  CLICKER BRIDGE - exam " + examId);
        System.out.println("  Server: " + server);
        System.out.println("  Simulator commands: 'K05 A' | auto | state | quit");
        System.out.println("==============================================");

        bridge.runConsoleSimulator();
    }

    private static int promptExamId() throws Exception {
        System.out.print("Exam ID: ");
        BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
        return Integer.parseInt(in.readLine().trim());
    }

    // ---------- live state polling ----------

    private void startPolling() {
        Thread t = new Thread(() -> {
            while (true) {
                try {
                    String json = httpGet(serverBase + "/api/liveState?examId=" + examId);
                    int qid = jsonInt(json, "questionId");
                    int qnum = jsonInt(json, "questionNumber");
                    int tot = jsonInt(json, "totalQuestions");
                    String st = jsonStr(json, "status");
                    if (qid > 0 && (qid != currentQuestionId || !st.equals(status))) {
                        currentQuestionId = qid;
                        questionNumber = qnum;
                        totalQuestions = tot;
                        status = st;
                        System.out.println("[STATE] Question " + qnum + "/" + tot
                                + " (id " + qid + ") - " + st);
                        if ("FINISHED".equals(st)) {
                            System.out.println("[STATE] Exam finished - answers no longer forwarded.");
                        }
                    }
                } catch (Exception e) {
                    System.out.println("[POLL] " + e.getMessage());
                }
                try { Thread.sleep(2000); } catch (InterruptedException ie) { return; }
            }
        });
        t.setDaemon(true);
        t.start();
    }

    // ---------- keypad event -> Answer API ----------

    /** Called for every keypad press. Real receiver code calls this too. */
    public void onKey(String clickerId, String key) {
        if (currentQuestionId <= 0) {
            System.out.println("[SKIP] No live question yet for " + clickerId);
            return;
        }
        if ("FINISHED".equals(status)) {
            System.out.println("[SKIP] Exam finished; ignoring " + clickerId);
            return;
        }
        try {
            String body = "examId=" + examId
                    + "&questionId=" + currentQuestionId
                    + "&clickerId=" + clickerId
                    + "&answer=" + key;
            String resp = httpPost(serverBase + "/api/answer", body);
            if (resp.contains("\"ok\"")) {
                System.out.println("[OK]   " + clickerId + " -> " + key
                        + " (Q" + questionNumber + ")");
            } else {
                System.out.println("[FAIL] " + clickerId + ": " + resp);
            }
        } catch (Exception e) {
            System.out.println("[ERR]  " + clickerId + ": " + e.getMessage());
        }
    }

    // ---------- simulator (until real hardware arrives) ----------

    private void runConsoleSimulator() throws Exception {
        BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
        Random rnd = new Random();
        String line;
        while ((line = in.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            if (line.equalsIgnoreCase("quit")) break;

            if (line.equalsIgnoreCase("state")) {
                System.out.println("[STATE] exam " + examId + ", question " + questionNumber
                        + "/" + totalQuestions + " (id " + currentQuestionId + "), " + status);
                continue;
            }

            if (line.equalsIgnoreCase("auto")) {
                // every dummy clicker answers the current question
                String[] keys = {"A", "B", "C", "D"};
                for (int i = 1; i <= 30; i++) {
                    onKey(String.format("K%02d", i), keys[rnd.nextInt(4)]);
                }
                continue;
            }

            String[] parts = line.toUpperCase().split("\\s+");
            if (parts.length == 2 && parts[1].matches("[ABCD]")) {
                onKey(parts[0], parts[1]);
            } else {
                System.out.println("Use: <clickerId> <A|B|C|D>   e.g.  K05 A");
            }
        }
        System.out.println("Bridge stopped.");
    }

    // ---------- tiny HTTP + JSON helpers (no libraries needed) ----------

    private static String httpGet(String url) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(3000);
        c.setReadTimeout(3000);
        return readBody(c);
    }

    private static String httpPost(String url, String form) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(3000);
        c.setReadTimeout(3000);
        c.setDoOutput(true);
        c.setRequestMethod("POST");
        c.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        try (OutputStream os = c.getOutputStream()) {
            os.write(form.getBytes(StandardCharsets.UTF_8));
        }
        return readBody(c);
    }

    private static String readBody(HttpURLConnection c) throws Exception {
        java.io.InputStream is = c.getResponseCode() < 400 ? c.getInputStream() : c.getErrorStream();
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String l;
            while ((l = r.readLine()) != null) sb.append(l);
        }
        return sb.toString();
    }

    private static int jsonInt(String json, String field) {
        java.util.regex.Matcher m = java.util.regex.Pattern
                .compile("\"" + field + "\"\\s*:\\s*(-?\\d+)").matcher(json);
        return m.find() ? Integer.parseInt(m.group(1)) : -1;
    }

    private static String jsonStr(String json, String field) {
        java.util.regex.Matcher m = java.util.regex.Pattern
                .compile("\"" + field + "\"\\s*:\\s*\"([^\"]*)\"").matcher(json);
        return m.find() ? m.group(1) : "";
    }
}
