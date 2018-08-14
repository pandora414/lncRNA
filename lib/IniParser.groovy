class Main {
    static void main(String[] args) {
        def ini = new IniParser("test/data.ini")
        ini.dumpConfig()
        println(ini.src)
        def secs = ini.getAllSections()
        secs.each() { it ->
            println it
        }
    }
}

class IniParser {
    def src = null;
    def sections = new ArrayList<String>();
    def config = [:]
    String section = ""
    boolean inSection = false;
    def match = null;
    int line_no=0
    IniParser(filename) {
        src = new File(filename)
        src.eachLine { line ->
            line_no++
            if(line=~'^#'){
                return
            }
            line.find(/\[(.*)\]/) {full, sec ->
                sections.add(sec)
                inSection = true;
                section = sec
                config[section] = [:]
            }
            line.find(/\s*(\w+)\.?(\w+)?\s*=\s*(.*)?(?:#|$)/) {full, key,attr, value ->

                if (config.get(section).containsKey(key)) {
                    def attrs = config.get(section).get(key)
                    attrs.put(attr,value)
                } else {
                    if (attr){
                        throw new Exception('error config file,miss key main value! line=\n'+line)
                    }
                    def attrs=[_value:value]
                    config.get(section).put(key, attrs)
                }
            }
        }
    }

    def dumpConfig() {
        config.each() {key, value ->
            println "$key: $value"
        }
    }

    ArrayList<String> getAllSections() {
        return sections
    }

    def getSection(s) {
        return config.get(s)
    }

    def getConfig() {
        return config
    }

    def getConfig(String section) {
        return config.get(section)
    }

    def getConfig(String section, String key) {
        return config.get(section).get(key)
    }
}