import PerfectCRUD
import PerfectMySQL

public struct CSCoreDB {
    public var host: String = "127.0.0.1"
    public var username: String = "bmserver"
    public var password: String = "B@r1m@x2016"
    public var database: String?
    public let port: Int = 3306
    public init(database: String){
        self.database = database
    }
    public init(host h: String, username u: String, password p: String){
        self.host = h
        self.username = u
        self.password = p
    }
}

public struct CSCoreDBConfig {
    public static var dbConfiguration: CSCoreDB?
}

