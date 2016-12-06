local cache = require("mj.cache")
local helper = {}
-- getHonorsType 获取字牌类型  A(mXXXX) B(mXXX+Y)  C(mXXX+YY) E(mXXX+YY+a) 
-- F(mXXX+YY+ZZ) H(mXXX+aa+bb+cc) Z(other)
function helper.getHonorsType(dct)
   local pairsCount = 0
   local singleCount = 0
   for k,v in pairs({'d','n','x','b','Z','F','B'}) do
      local count = dct[v]
      if count == 1 or count == 4 then
         singleCount = singleCount + 1
      elseif count == 2 then
         pairsCount = pairsCount + 1
      end
   end
   if singleCount > 1 then
      return 'Z'
   elseif singleCount == 1 then
      if pairsCount == 0 then
         return 'B'
      elseif pairsCount == 1 then
         return 'E'
      end
   elseif pairsCount == 0 then
      return 'A'
   elseif pairsCount == 1 then
      return 'C'
   elseif pairsCount == 2 then
      return 'F'
   elseif pairsCount == 3 then
      return 'H'
   end
   return 'Z'
end

-- getSuitsType 获取色牌类型  
---A(mXXXX) B(mXXX+Y) C(mXXX+nYY) D(mXXX + ab) E(mXXX+YY+a,mXXX+ab+c)
-- F(mXXX+YY+ZZ,mXXX+YY+ab) G(mXXX+ab+cd) H(mXXX+aa+bb+cc) Z(other)
function helper.getSuitsType(dct)
   local function pong_available(dct,card)
      if dct[card] >= 3 then
         return {card,card,card}
      end
   end
   
   local function chow_available(dct,card)
      local res = {}
      local l1 = card - 1
      local l2 = l1 - 1

      local n1 = card + 1 
      local n2 = n1 + 1
      
      if l1 and l2 and dct[l1] and dct[l2] then
         if dct[l1] > 0 and dct[l2] > 0 then
            res[#res + 1] =  {l2,l1,card}
         end
      end
      if n1 and n2 and dct[n1] and dct[n2] then
         if dct[n1] > 0 and dct[n2] > 0 then
            res[#res + 1] =  {card,n1,n2}
         end
      end
      if l1 and n1 and dct[l1] and dct[n1] then
         if dct[l1] > 0 and dct[n1] > 0 then
            res[#res + 1] =  {l1,card,n1}
         end
      end
      return res
   end

   local function getType(dct)
      local cards = {}
      for k,v in pairs(dct) do
         for i = 1,v do
            cards[#cards + 1] = k
         end
      end
      if #cards == 0 then
         return 'A'
      end

      if #cards == 1 then
         return 'B'
      end
      if #cards == 2 then
         if cards[1] == cards[2] then
            return 'C'
         else
            local rank1,rank2 = cards[1],cards[2]
            if math.abs(rank1-rank2) <=2 then
               return 'D'
            end
         end
      end

      if #cards == 3 then
         local rank1,rank2,rank3 = cards[1],cards[2],cards[3]
         if rank1 == rank2 or rank2 == rank3 or rank1 == rank3 then
            return 'E'
         end
         if math.abs(rank1 -rank2) <= 2 or math.abs(rank1- rank3) <= 2 or math.abs(rank2- rank3) <=2 then
            return 'E'
         end 
      end
      if #cards == 4 then
         table.sort( cards)         
         local rank1,rank2,rank3,rank4 = cards[1],cards[2],cards[3],cards[4]
         if rank1 == rank2 then
            if math.abs(rank3-rank4) <= 2 then
               return 'F'
            end
         end
         if rank3 == rank4 then
            if math.abs(rank1-rank2) <= 2 then
               return 'F'
            end
         end
         
         if math.abs(rank1-rank2) <= 2 and math.abs(rank3-rank4) <=2 then
            return 'G'
         end
      end

      if #cards == 6 then
         table.sort(cards)
         if cards[1] == cards[2] and cards[3] == cards[4] and cards[5] == cards[6] then
            return 'H'
         end
      end
      return 'Z'
   end
   local function operate( dct,operator)
      local newDct = clone(dct)
      for i,j in ipairs(operator) do
         newDct[j] = newDct[j] - 1
      end
      return newDct
   end

   local function getCache(dct,cache)
      local key = ""
      for i = 1,9 do
         key = key..dct[i]
      end
      return cache[key] or 'Z'
   end

   local function chooseBestType(a,b)
      if a < b then
         return a
      else
         return b
      end
   end
   local bestType = 'Z'

   bestType = chooseBestType(bestType,getCache(dct,cache))
     
   local has = false
   for k,v in pairs(dct) do
      if v > 0 then
         has = true
         local operators = chow_available(dct, k)
         local pong = pong_available(dct,k)
         if pong then
            operators[#operators + 1] = pong 
         end
         
         if #operators == 0 then
            local type = getType(dct)
            
            bestType = chooseBestType(bestType,type)
            if bestType == 'A' or bestType == 'B' or bestType == 'C' then
               return bestType
            end
         end
         for i,j in ipairs(operators) do
            local newDct = operate(dct,j)
            local type = getSuitsType(newDct)
            bestType = chooseBestType(bestType,type)
            if bestType == 'A' or bestType == 'B' or bestType == 'C' then
               return bestType
            end
         end         
      end
   end
   if not has then
      return 'A'
   end  

   return bestType
end

return helper