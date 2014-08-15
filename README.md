# Dump JCR content to MongoDB

Connects to JCR at `localhost:4502` and MongoDB at `localhost` by default.

```
$ sbt
> console
> val d = saml.JackrabbitMongodbDump(saml.jcr.Connection(), saml.mongo.Mongo().client("jackrabbit_dump")("pages"))
> d.start("/content/nymag/daily", """/\d\d\d\d/\d\d/[^/]+/jcr:content$""".r)
```

# Other Examples

```
$ sbt
> console
> val c = saml.jcr.Connection(url="http://localhost:8080/server", username="admin", password="admin")
> c.xpath("/jcr:root/content//element(*,cq:Page)").foreach(x => println(x.getPath))
> saml.jcr.allNodes(c.nodeAt("/content/foo/bar")).foreach( x => println(x.getPath))
```