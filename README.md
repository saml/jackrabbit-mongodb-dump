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

# Using Sling

`DavEx` is really slow. So use [sling](http://sling.apache.org/) instead. Sling scripts are located under [sling/jcr_root](sling/jcr_root).

Assumming sling is at localhost:4502,

```
curl -u admin:admin -F"sling:resourceType=saml/mongodump"  http://localhost:4502/apps/saml/mongodump
curl -u admin:admin -T sling/jcr_root/apps/saml/mongodump/html.jsp http://localhost:4502/apps/saml/mongodump/html.jsp
curl -u admin:admin -T sling/jcr_root/apps/saml/mongodump/POST.jsp http://localhost:4502/apps/saml/mongodump/POST.jsp
curl -u admin:admin -F "path=/content/nymag/daily" http://localhost:4502/apps/saml/mongodump.html > out.json
mongoimport -d cq_dump -c pages --file out.json
```


