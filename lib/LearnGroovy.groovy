class Student implements GroovyInterceptable {
    protected dynamicProps = [:]

    void setProperty(String pName, val) {
        dynamicProps[pName] = val
    }

    def getProperty(String pName) {
        dynamicProps[pName]
    }

    def methodMissing(String name, def args) {
        println "Missing method"
    }
}

class LearnGroovy {
    static void main(String[] args) {
        Student mst = new Student()
        mst.name='asdf'
        mst.setProperty('sex','1')

        println mst.name
        print mst.sex
    }

}


