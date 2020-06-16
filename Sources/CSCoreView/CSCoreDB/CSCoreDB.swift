import PerfectCRUD
import PerfectMySQL

public struct CSCoreDB {
    public var host: String = "127.0.0.1"
    public var username: String = "bmserver"
    public var password: String = "B@r1m@x2016"
    public var database: String?
    public var masterDatabase: String
    public let port: Int = 3306
//    public init(database: String){
//        self.database = database
//    }
    public init(host h: String, username u: String, password p: String, masterDatabase mdb: String){
        self.host = h
        self.username = u
        self.password = p
        self.masterDatabase = mdb
    }
}

public struct CSCoreDBConfig {
    public static var dbConfiguration: CSCoreDB?
}

