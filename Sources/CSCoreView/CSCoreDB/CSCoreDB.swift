import PerfectCRUD
import PerfectMySQL

public struct CSCoreDB {
    public let host: String
    public let username: String
    public let password: String
    public let database: String
    public let port: Int = 3306
    
    public init(
        host: String,
        username: String,
        password: String,
        database: String
        ){
        self.host = host
        self.username = username
        self.password = password
        self.database = database
    }
}

public struct CSCoreDBConfig {
    public static var dbConfiguration: CSCoreDB?
}

