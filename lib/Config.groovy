import IniParser

class Item implements  GroovyInterceptable{
    public String name=""
    String default_value=""

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

    Item(name,value){
        this.name=name
        for(_item in value){
            _item.each{
                setProperty(it.key,it.value)
            }
        }
    }
}



class Section {
    String name=""
    int count=0
    def items=new ArrayList<Item>()

    public Section(name,sec){
        this.name=name
        Item item=null
        for(_item in sec){
            _item.each{
                item=new Item(it.key,it.value)
                print(item.name)
                items.add(item)
            }
        }
    }
}



class Config {
    def filename=""
    def ini=null
    def data_dir=null
    Config(filename){
        this.filename=filename
        ini=new IniParser(filename)
        data_dir=new File(filename).getParent()
    }
    def ReadSamples() {
        def sec=ini.getSection('sample')
        def res=[]

        for(item in sec){
            def files=[]
            item.each{
                for(filename in it.value.split("\\|")){
                    if(filename =~'^/'){
                        files.add(filename)
                    }else{
                        files.add(data_dir+'/'+filename)
                    }
                }
                res.add([it.key,files])
            }
        }
        return res
    }
    def ReadGroups(){
        def sec=ini.getSection('group')
        def res=[]
        for(item in sec){
            item.each{
                res.add([it.key,it.value.split(',')[0],it.value.split(',')[1],it.value.split(',')])
            }
        }
        return res
    }

    def ReadSection(String section_name){
        def sec=ini.getSection(section_name)
        Section s=new Section(section_name,sec)
        return s
    }

    static void main(String[] args) {
        def config=new Config('test/data.ini')
        def s=config.ReadSection('sample')
        println(s.items[0].name)
    }
}
