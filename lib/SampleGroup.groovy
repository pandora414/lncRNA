class SampleGroup {
    static def group(s_list, g) {
        def ss = s_list
        def ns = []

        def n = ['name': g['name'], 'value': [:]]
        for (s in ss) {
            if (g['value'].contains(s['name'])) {
                n['value'].put(s['name'],s['value'])
            }
        }
        println n
        ns.add(n)
        return ns
    }
    static def make_group(g,samples){
        def group_name=g[0]
        def group_sample_names=g[1]
        def values=[]
        for(item in samples){
            item.each{
                if(group_sample_names.contains(it.key)){
                    values.add(item)
                }
            }
        }
        return [group_name,values]
    }
    static def print(groups){
        for(group in groups){
            println group
        }
    }
    static void main(String[] args) {
        def ss = [['name': 's1', 'value': 1], ['name': 's2', 'value': 2], ['name': 's3', 'value': 3]]
        def gs = [['name': 'g1', 'value': ['s1', 's2']], ['name': 'g2', 'value': ['s1', 's3']], ['name': 'g3', 'value': ['s2', 's3']]]
        for (g in gs){
            group(ss, g)
        }

        def groups=[["group1", ["sample1, sample2"]],["group2", ["sample2", "sample3"]]]
    }
}

