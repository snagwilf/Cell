struct Cell {
    var text = "Hello, World!"
}

protocol Keyed {
    associatedtype Key: Hashable
    var key: Key { get }
}

struct KeyedMap<K: Keyed> {
    private var data: Dictionary<K.Key, K>
    init() {
        data = Dictionary()
    }
    init<S>(_ keysAndValues: S) throws where S : Sequence, S.Element == K {
        data = Dictionary(
            keysAndValues.map({ k in (k.key, k)}),
            uniquingKeysWith: { (_, _) in fatalError("Duplicate key.") })
    }
    
    @discardableResult mutating func updateValue(_ value: K) -> K? {
        data.updateValue(value, forKey: value.key)
    }
    func view() -> Dictionary<K.Key, K> { data }
}

struct Animal : Keyed {
    var key: String
    init(_ name: String) { key = name }
}

func test() -> String {
    let t = O2O<Int, Int>()
    var f = t.fwd
    f[1] = 1
    return String(t.fwd.count)
}

struct O2O<K: Hashable, V: Hashable> {
    private var _fwd: Dictionary<K, V>
    private var _bwd: Dictionary<V, K>
    
    var fwd: Dictionary<K, V> { _fwd }
    var bwd: Dictionary<V, K> { _bwd }
    
    init() {
        _fwd = Dictionary()
        _bwd = Dictionary()
    }
    
    private static func update<A, B>(_ ad: inout Dictionary<A, B>, _ a: A, _ bd: inout Dictionary<B, A>, _ b: B?) {
        let oldB = ad[a]
        if oldB != nil { bd[oldB!] = nil }
        ad[a] = b
    }
    
    subscript(key: K) -> V? {
        get { _fwd[key] }
        set {
            O2O.update(&_fwd, key, &_bwd, newValue)
            if newValue != nil {
                O2O.update(&_bwd, newValue!, &_fwd, key)
            }
        }
    }
    
    mutating func remove(value: V) -> K? {
        let key = _bwd[value]
        if key != nil { _fwd[key!] = nil }
        return key
    }
}

protocol Container {
    associatedtype Item
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}
extension Array: Container { }
extension Dictionary: Container {
    subscript(i: Int) -> (Key, Value) {
        let r = randomElement()!
        return (r.key, r.value)
    }
    
    typealias Item = (Dictionary.Key, Dictionary.Value)
}

func makeOpaqueContainer<T: Hashable>(item: T) -> some Container {
    return [item]
}

func makeOpaqueContainer2<T: Hashable>(item: T) -> some Container {
    return Dictionary<T, T>(dictionaryLiteral: (item, item))
}

func makeOpaqueContainer3<T: Hashable>(item: T) -> some Container {
    return [item]
}

public func testOpaque() {
    let opaqueContainer = makeOpaqueContainer(item: 12)
    //let twelve = opaqueContainer[0]
    print(type(of: opaqueContainer))
}

protocol Shape {
    func draw() -> String
}

struct Triangle: Shape {
    var size: Int
    func draw() -> String {
        var result = [String]()
        for length in 1...size {
            result.append(String(repeating: "*", count: length))
        }
        return result.joined(separator: "\n")
    }
}

struct FlippedShape<T: Shape>: Shape {
    var shape: T
    func draw() -> String {
        let lines = shape.draw().split(separator: "\n")
        return lines.reversed().joined(separator: "\n")
    }
}

struct JoinedShape<T: Shape, U: Shape>: Shape {
    var top: T
    var bottom: U
    func draw() -> String {
        return top.draw() + "\n" + bottom.draw()
    }
}

struct Square: Shape {
    var size: Int
    func draw() -> String {
        let line = String(repeating: "*", count: size)
        let result = Array<String>(repeating: line, count: size)
        return result.joined(separator: "\n")
    }
}

func makeTrapezoid() -> some Shape {
    let top = Triangle(size: 2)
    let middle = Square(size: 2)
    let bottom = FlippedShape(shape: top)
    let trapezoid = JoinedShape(
        top: top,
        bottom: JoinedShape(top: middle, bottom: bottom)
    )
    return trapezoid
}

func protoFlip<T: Shape>(_ shape: T) -> some Shape {
    return FlippedShape(shape: shape)
}


