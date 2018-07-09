import IniParser
class Config {
    def filename;
    def ini=null;
    def data_dir=null;
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

    static void main(String[] args) {
        def config=new Config('config.ini')
        config.ReadSamples()
        config.ReadGroups()
    }
}
