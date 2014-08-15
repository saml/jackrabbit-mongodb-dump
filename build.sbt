libraryDependencies ++= Seq(
  "javax.jcr" % "jcr" % "2.0" % "compile",
  "org.apache.jackrabbit" % "jackrabbit-core" % "2.8.0" withSources(),
  "org.apache.jackrabbit" % "jackrabbit-jcr2dav" % "2.8.0",
  "org.mongodb" %% "casbah" % "2.7.3"
)
