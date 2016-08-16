local sqlStr = {}

sqlStr["Query_User_Passwrod"] = "select password from user where username = %s"
sqlStr["Query_User_Info"] = "select * from user where username = %s"

return sqlStr