import java.util.*;
import java.io.*;
import java.net.*;
import java.nio.file.*;

public class LatestBuild {

  private static final String USER_AGENT = "Mozilla/5.0";
  private static final String SURVEYSVC = "surveysvc";
  private static final String[] SERVICES = {"actionsvc", "actionexportersvc",
                                      "casesvc", "collectionexercisesvc",
                                      "iacsvc", "samplesvc", "surveysvc",
                                      "notifygatewaysvc", "sdxgatewaysvc"};
  private static final String USAGE = "USAGE: java LatestBuild [-n] [-g] " +
                                      "<Host> <HomeDir> <Service>\n" +
                                      "-n   get name of latest version\n" +
                                      "-g   download latest version of " +
                                      "service\n";
  private static final int SERVICE_NAME_INDEX = 12;

  public static void main(String[] args) {

    String ext = "";
    String optn = "";
    String host = "";
    String home = "";
    String service = "";

    if (args.length == 4 || args.length == 5) {
      optn = args[0];
      host = args[1];
      home = args[2] + "/";
      service = args[3];
      if (args.length == 5 && optn.equals("-g")) {
        String sha = args[4];
        ext = ".git.sha" + sha;
      } else if (args.length == 4 && optn.equals("-n")) {
          if (service.equals(SURVEYSVC)) {
            ext = ".tar";
          }
          else ext = ".jar";
      } else {
        System.err.println(USAGE);
        System.exit(1);
      }
    } else {
      System.err.println(USAGE);
      System.exit(1);
    }

    if (!Arrays.asList(SERVICES).contains(service)) {
      System.err.println("Error! Service <" + service + "> does not exist!");
      System.exit(1);
    }

    String url = "" + host + "/artifactory/api/search/artifact?name=" +
       service + "*" + ext + "&repos=libs-snapshot-local";

    try {
      String snapshotList = getList(url, service, ext, home);
      String snapshotUrl = getSnapshotUrl(snapshotList, service);
      if (optn.equals("-g")) {
        getSvc(snapshotUrl, home);
      } else if (optn.equals("-n")) {
        getName(snapshotUrl, home, service);
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }

  private static String getList(String uri, String svc, String ext, String home)
      throws IOException {

    HttpURLConnection connection = getConnection(uri);

    BufferedReader br = new BufferedReader(
      new InputStreamReader(connection.getInputStream()));

    StringBuffer response = new StringBuffer();
    String output;
    while ((output = br.readLine()) != null) {
      response.append(output);
    }

    br.close();
    connection.disconnect();
    return response.toString();
  }

  private static String getSnapshotUrl(String snapshotList, String service) {

    snapshotList = snapshotList.replaceAll("[\"\\} \\n\\{\\[\\]]*", "");
    snapshotList = snapshotList.replaceAll("results:uri:", "");
    snapshotList = snapshotList.replaceAll("api/storage/", "");

    List<String> snapshots = new ArrayList<String>(Arrays.asList(snapshotList
      .split("\\,uri\\:")));
    int urls = snapshots.size();
    String url = "";
    if (service.equals(SURVEYSVC)) {
      snapshotList = snapshotList.replaceAll("[a-zA-Z\\.\\/\\-\\:]*", "");
      List<String> surveyVersions = new ArrayList<String>(Arrays
        .asList(snapshotList.split("\\,")));

      List<Integer> versionsNo = new ArrayList<Integer>();
      for (String s : surveyVersions) {
        versionsNo.add(Integer.parseInt(s));
      }
      Collections.sort(versionsNo);
      int i = 0 ;
      for (Integer v : versionsNo) {
        surveyVersions.set(i, v.toString());
        i++;
      }
      i=0;
      for (String snapshot : snapshots) {
        if (snapshot.contains(surveyVersions.get(surveyVersions.size()-1))) {
          url = snapshot;
        }
        i++;
      }
    }
    else url = snapshots.get(urls-1);
    return url;
  }

  private static void getName(String snapshotUrl, String home, String svc)
      throws FileNotFoundException {

    String[] pathComponents = snapshotUrl.split("/");
    String svcVersion = pathComponents[SERVICE_NAME_INDEX]
      .replaceAll(".jar", ".git.sha");

    System.out.println(svcVersion);
  }

  private static void getSvc(String uri, String home)
      throws IOException {

    String url = uri.replaceAll("\\.git\\.sha.*$", ".jar");
    System.out.println(url);
    HttpURLConnection connection = getConnection(url);

    BufferedReader br = new BufferedReader(
      new InputStreamReader(connection.getInputStream()));
    String[] urlComponents = url.split("/");
    String filePath = home + urlComponents[12];
    Path path = Paths.get(filePath);
    Files.copy(connection.getInputStream(), path);
    br.close();
    connection.disconnect();
  }

  private static HttpURLConnection getConnection(String uri)
      throws MalformedURLException, IOException, ProtocolException {
    URL url = new URL(uri);
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
    connection.setRequestMethod("GET");
    connection.setRequestProperty("User-Agent", USER_AGENT);

    return connection;
  }
}
