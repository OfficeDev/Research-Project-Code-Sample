RESEARCH TRACKER ANDROID CLIENT
===============================

## Dependencies

-   [Maven](http://maven.apache.org/download.cgi)
-   [Java 7 JDK](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)
-   [Android Studio](https://developer.android.com/sdk/installing/studio.html)
-   [Olingo OData 4.0](https://github.com/apache/olingo-odata4)
-   [O365 Android SDK](https://github.com/MSOpenTech/O365-Android)

# Clone and build Olingo

    > git clone https://github.com/apache/olingo-odata4.git
    > cd olingo-odata4
    > mvn -DskipTests -pl :odata-client-android -am clean install 

# Clone and build O365-Android Lists SDK

    > git clone git@github.com:MSOpenTech/O365-Android.git
    > cd O365-Android\sdk\office365-lists-files-sdk
    > mvn clean install

## Other things

