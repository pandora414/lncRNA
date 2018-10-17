class Main {
    static void main(String[] args) {
        def ini = new IniParser("test/data.ini")
        ini.dumpConfig()
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
    IniParser(filename) {
        src = new File(filename)
        src.eachLine { line ->
            if(line=~'^#'){
                return
            }
            line.find(/\[(.*)\]/) {full, sec ->
                sections.add(sec)
                inSection = true;
                section = sec
                config[section] = [:]
            }
            line.find(/\s*(\S+)\s*=\s*(.*)?(?:#|$)/) {full, key, value ->
                if (config.get(section).containsKey(key)) {
                    def v = config.get(section).get(key)
                    if (v in Collection) {
                        def oldVal = config.get(section).get(key)
                        oldVal.add(value)
                        config[key] = oldVal
                        config.get(section).put(key, oldVal)
                    } else {
                        def values = new ArrayList<String>();
                        values.add(v)
                        values.add(value)
                        config.get(section).put(key, values)
                    }
                } else {
                    config.get(section).put(key, value)
                }
                // println "Match: $full, Key: $key, Value: $value"
                // config.get(section).put(key, value)
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