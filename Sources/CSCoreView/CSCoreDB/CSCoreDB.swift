import PerfectCRUD
import PerfectMySQL

public struct CSCoreDB {
    public let host: String = "127.0.0.1"
    public let username: String = "bmserver"
    public let password: String = "B@r1m@x2016"
    public let database: String
    public let port: Int = 3306
    public init(database: String){
        self.database = database
    }
}

public struct CSCoreDBConfig {
    public static var dbConfiguration: CSCoreDB?
}

