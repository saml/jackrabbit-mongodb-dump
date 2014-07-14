// vim: set ts=4 sw=4 et:

import sbt._
import Keys._

object MuchBuild extends Build {
  libraryDependencies ++= Seq(
    "javax.jcr" % "jcr" % "2.0" % "compile",
    "org.apache.jackrabbit" % "jackrabbit-core" % "2.8.0" withSources(),
    "org.apache.jackrabbit" % "jackrabbit-jcr2dav" % "2.8,0"
  )
}
