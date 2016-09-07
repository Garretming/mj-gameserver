local sqlStr = {}

sqlStr["Query_User_Passwrod"] = [[select password from user where username = %s and deleted_at is NULL]]
sqlStr["Query_User_Info"] = [[select nickname,mobilephone,gold,gem from user where 
                                username = %s and deleted_at is NULL]]

return sqlStr