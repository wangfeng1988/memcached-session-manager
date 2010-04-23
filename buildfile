# Generated by Buildr 1.3.3, change to your liking
# Standard maven2 repository
require 'etc/checkstyle'

repositories.remote << 'http://repo2.maven.org/maven2'
repositories.remote << 'http://www.ibiblio.org/maven2'
repositories.remote << 'http://thimbleware.com/maven'
repositories.remote << 'http://repository.jboss.com/maven2'
#repositories.remote << 'http://powermock.googlecode.com/svn/repo'

SERVLET_API = 'javax.servlet:servlet-api:jar:2.5'
CATALINA = 'org.apache.tomcat:catalina:jar:6.0.26'
CATALINA_HA = 'org.apache.tomcat:catalina-ha:jar:6.0.26'
TC_COYOTE = transitive( 'org.apache.tomcat:coyote:jar:6.0.26' )
MEMCACHED = artifact('spy.memcached:spymemcached:jar:2.4.2').from(file('lib/memcached-2.4.2.jar'))
JAVOLUTION = artifact('javolution:javolution:jar:5.4.3.1').from(file('lib/javolution-5.4.3.1.jar'))
XSTREAM = transitive( 'com.thoughtworks.xstream:xstream:jar:1.3.1' )

# Kryo
KRYO_SERIALIZERS = artifact( 'de.javakaffee:kryoserializers:jar:0.2' ).from(file('lib/kryo-serializers-0.2.jar'))
KRYO = artifact( 'com.esotericsoftware:kryo:jar:1.1-SNAPSHOT' ).from( file( 'lib/kryo-1.1-SNAPSHOT.jar' ) )
REFLECTASM = artifact('com.esotericsoftware:reflectasm:jar:0.8').from(file('lib/reflectasm-0.8.jar'))
MINLOG = artifact('com.esotericsoftware:minlog:jar:1.2').from(file('lib/minlog-1.2.jar'))
ASM = 'asm:asm:jar:3.2'

# Custom converter libs
JODA_TIME = 'joda-time:joda-time:jar:1.6'
CGLIB = transitive( 'cglib:cglib:jar:2.2' )
WICKET = transitive( 'org.apache.wicket:wicket:jar:1.4.7' )

# Testing
JMEMCACHED = transitive( 'com.thimbleware.jmemcached:jmemcached-core:jar:0.9.1' ).reject { |a| a.group == 'org.slf4j' }
HTTP_CLIENT = transitive( 'org.apache.httpcomponents:httpclient:jar:4.1-alpha1' )
SLF4J = transitive( 'org.slf4j:slf4j-simple:jar:1.5.6' )
JMOCK_CGLIB = transitive( 'jmock:jmock-cglib:jar:1.2.0' )
CLANG = 'commons-lang:commons-lang:jar:2.4' # tests of javolution-serializer, xstream-serializer
MOCKITO = transitive( 'org.mockito:mockito-core:jar:1.8.1' )

# Dependencies
require 'etc/tools'

LIBS = [ CATALINA, CATALINA_HA, MEMCACHED, JMEMCACHED, TC_COYOTE, HTTP_CLIENT, SLF4J, XSTREAM ]
task("check-deps") do |task|
  checkdeps LIBS      
end                         

task("dep-tree") do |task|
  deptree LIBS
end

desc 'memcached-session-manager (msm for short): memcached based session failover for Apache Tomcat'
define 'msm' do
  project.group = 'de.javakaffee.web.msm'
  project.version = '1.3.1'

  compile.using :source=>'1.6', :target=>'1.6'
  test.using :testng
  package :sources, :javadoc
  package_with_javadoc
  package_with_sources

  checkstyle.config 'etc/checkstyle-checks.xml'
  checkstyle.style 'etc/checkstyle.xsl'

  desc 'The core module of memcached-session-manager'
  define 'core' do |project|
    compile.with( SERVLET_API, CATALINA, CATALINA_HA, TC_COYOTE, MEMCACHED )
    test.with( JMEMCACHED, HTTP_CLIENT, SLF4J, JMOCK_CGLIB, MOCKITO )
    package :jar, :id => 'memcached-session-manager'
  end

  desc 'Javolution/xml based serialization strategy'
  define 'javolution-serializer' do |project|
    compile.with( projects('core'), project('core').compile.dependencies, JAVOLUTION )
    test.with( compile.dependencies, project('core').test.dependencies, CLANG )
    package :jar, :id => 'msm-javolution-serializer'
  end

  desc 'Converter for Joda DateTime instances for javolution serialization strategy'
  define 'javolution-serializer-jodatime' do |project|
    compile.with( projects('javolution-serializer'), project('javolution-serializer').compile.dependencies, JODA_TIME )
    test.with( compile.dependencies, MOCKITO )
    package :jar, :id => 'msm-javolution-serializer-jodatime'
  end

  desc 'Converter for cglib proxies for javolution serialization strategy'
  define 'javolution-serializer-cglib' do |project|
    compile.with( projects('javolution-serializer'), project('javolution-serializer').compile.dependencies, CGLIB )
    test.with( compile.dependencies, MOCKITO )
    package :jar, :id => 'msm-javolution-serializer-cglib'
  end

  desc 'XStream/xml based serialization strategy'
  define 'xstream-serializer' do |project|
    compile.with( projects('core'), project('core').compile.dependencies, XSTREAM )
    test.with( compile.dependencies, project('core').test.dependencies, CLANG )
    package :jar, :id => 'msm-xstream-serializer'
  end

  desc 'Kryo/binary serialization strategy'
  define 'kryo-serializer' do |project|
    compile.with( projects('core'), project('core').compile.dependencies, KRYO_SERIALIZERS, KRYO, REFLECTASM, ASM, MINLOG, JODA_TIME, WICKET )
    test.with( compile.dependencies, project('core').test.dependencies, CLANG )
    package :jar, :id => 'msm-kryo-serializer'
  end

  desc 'Benchmark for serialization strategies'
  define 'serializer-benchmark' do |project|
    compile.with( projects('core'), project('core').compile.dependencies, projects('javolution-serializer'), project('javolution-serializer').compile.dependencies, projects('kryo-serializer'), project('kryo-serializer').compile.dependencies, CLANG )
    #test.with( compile.dependencies, CLANG )
    test.with( CLANG )
    package :jar, :id => 'msm-serializer-benchmark'
  end

end
