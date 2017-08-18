
import java.util.*;
import java.io.*;
import java.net.*;
import java.nio.file.*;

public class LatestBuild {

  private static final String USER_AGENT = "Mozilla/5.0";
  private static final String[] SERVICES = {"actionsvc","actionexportersvc","casesvc","collectionexercisesvc",
  "iacsvc","samplesvc","surveysvc","notifygatewaysvc","sdxgatewaysvc"};
  private static final String SURVEYSVC = "surveysvc";

  public static void main(String[] args){
    try {
      String host = args[0];
      String home = args[1] + "/";
      String service = args[2];
      String ext;
      if(!Arrays.asList(SERVICES).contains(service)) {
        System.out.println("Error! Service <" + service + "> does not exist!");
        System.exit(0);
      }
      if (service.equals(SURVEYSVC)) {
        ext = ".tar";
      }
      else ext = ".jar";
      String url = "" + host + "/artifactory/api/search/artifact?name=" + service + "*" + ext + "&repos=libs-snapshot-local";
      String snapshotList = getList(url,service,ext,home);
      String snapshotUrl = getSnapshotUrl(snapshotList,service);
      getSvc(snapshotUrl,service,ext,home);
    } catch(Exception e){
      System.out.println(e);
    }
  }

  private static String getSnapshotUrl(String snapshotList, String service){
    snapshotList = snapshotList.replaceAll("[\"\\} \\n\\{\\[\\]]*","");
    snapshotList = snapshotList.replaceAll("results:uri:","");
    snapshotList = snapshotList.replaceAll("api/storage/","");

    List<String> snapshots = new ArrayList<String>(Arrays.asList(snapshotList.split("\\,uri\\:")));
    int urls = snapshots.size();
    String url = "";
    if(service.equals(SURVEYSVC)) {
      snapshotList = snapshotList.replaceAll("[a-zA-Z\\.\\/\\-\\:]*","");
      List<String> surveyVersions = new ArrayList<String>(Arrays.asList(snapshotList.split("\\,")));
      List<Integer> versionsNo = new ArrayList<Integer>();
      for(String s : surveyVersions){
        versionsNo.add(Integer.parseInt(s));
      }
      Collections.sort(versionsNo);
      int i = 0 ;
      for(Integer v : versionsNo) {
        surveyVersions.set(i, v.toString());
        i++;
      }
      i=0;
      for(String snapshot : snapshots) {
        if(snapshot.contains(surveyVersions.get(surveyVersions.size()-1))){
          url = snapshot;
        }
        i++;
      }
    }
    else url = snapshots.get(urls-1);
    return url;
  }

  private static String getList(String uri,String svc, String ext,String home) throws IOException{
    URL url = new URL(uri);
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
    connection.setRequestMethod("GET");
    connection.setRequestProperty("User-Agent", USER_AGENT);

    BufferedReader br = new BufferedReader(
      new InputStreamReader(connection.getInputStream()));

    StringBuffer response = new StringBuffer();
    String output;
    while ((output = br.readLine()) != null) {
      response.append(output);
    }
    br.close();
    return response.toString();
  }

  private static void getSvc(String uri,String svc, String ext,String home) throws IOException{
    System.out.println(uri);
    URL obj = new URL(uri);
    HttpURLConnection connection = (HttpURLConnection) obj.openConnection();
    connection.setRequestMethod("GET");
    connection.setRequestProperty("User-Agent", USER_AGENT);

    int responseCode = connection.getResponseCode();

    BufferedReader br = new BufferedReader(
            new InputStreamReader(connection.getInputStream()));

    StringBuffer response = new StringBuffer();
    String p = home + svc + ext;
    Path path = Paths.get(p);
    Files.copy(connection.getInputStream(), path);
    br.close();
  }
}
