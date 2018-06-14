ss = [['name': 's1', 'value': 1], ['name': 's2', 'value': 2], ['name': 's3', 'value': 3]]
gs = [['name': 'g1', 'value': ['s1', 's2']], ['name': 'g2', 'value': ['s1', 's3']], ['name': 'g3', 'value': ['s2', 's3']]]
ns = []

for (g in gs) {
    n=['name':g['name'],'value':[]]
    for (s in ss) {
        if (g['value'].contains(s['name'])) {
            n['value'].add(s['value'])
        }
    }
    println n
    ns.add(n)
}
println ns

def aa='aaa'
aa+='cc'
println aa


myfile=new File('../data/config.ini')
println myfile.getParent()


