```
$ sbt
> console
> import saml.jcr._
> val c = Connection()
> val nodes = c.xpath("/jcr:root/content//element(*,cq:Page)")
> nodes.foreach { x => println(x.getPath) }
```