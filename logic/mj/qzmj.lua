--部分翻译参考 http://www.xqbase.com/other/mahjongg_english.htm
--泉州麻将
clsQZMJ = class('clsQZMJ')

local helper = require("mj.helper")
local CARD_ALL = {
   '1W','2W','3W','4W','5W','6W','7W','8W','9W',--万
   '1W','2W','3W','4W','5W','6W','7W','8W','9W',
   '1W','2W','3W','4W','5W','6W','7W','8W','9W',
   '1W','2W','3W','4W','5W','6W','7W','8W','9W',
   '1T','2T','3T','4T','5T','6T','7T','8T','9T',--筒
   '1T','2T','3T','4T','5T','6T','7T','8T','9T',
   '1T','2T','3T','4T','5T','6T','7T','8T','9T',
   '1T','2T','3T','4T','5T','6T','7T','8T','9T',
   '1S','2S','3S','4S','5S','6S','7S','8S','9S',--索
   '1S','2S','3S','4S','5S','6S','7S','8S','9S',
   '1S','2S','3S','4S','5S','6S','7S','8S','9S',
   '1S','2S','3S','4S','5S','6S','7S','8S','9S',
   'd','n','x','b','Z','F','B',
   'd','n','x','b','Z','F','B',
   'd','n','x','b','Z','F','B',
   'd','n','x','b','Z','F','B',
   "H11","H12","H13","H14",--黑花1234
   "H21","H22","H33","H44"--红花1234
}

local CARD_FLOWER = {"H11","H12","H13","H14","H21","H22","H33","H44"}

local CARD_GOLD = 'O'

--确认牌是144张
assert(#CARD_ALL == 144)

local CARD2INDEX = {}
for k,v in pairs(CARD_ALL) do
   CARD2INDEX[v] = k
end

local PLAYER_CARD_NUM = 16


--Fisher-Yates Shuffle
function shuffle(list)
   for i = #list, 1, -1 do
     local j = math.random(i)
     list[i], list[j] = list[j], list[i]
   end
   return list
end

function isValidCard( ... )
   local testCards = {...}
   if #testCards == 0 then
      return false
   end
   for k,v in ipairs(testCards) do
      if CARD2INDEX[v] == nil then
         return false
      end
   end
   return true
end
function getSuit( ... )
   local cards = {...}
   for i,j in ipairs(cards) do
      local suit = string.sub(j,2,2)
      cards[i] = suit
   end
   return unpack(cards)
end

function getRank( ... )
   local cards = {...}
   for i,j in ipairs(cards) do
      local rank = string.sub(j,1,1)
      cards[i] = toint(rank)
   end
   return unpack(cards)
end

function isSameSuit( ... )
   if not isValidCard(...) then
      return false
   end
   local suits = {getSuit(...)}
   local suit = nil
   for i,j in pairs(suits) do
      if suit == nil then
         suit = j
      elseif suit ~= j then
         return false
      end
   end
   return true
end


function isSequence(a,b,c)
   if not(a and b and c ) then
      return false
   end
   if not isValidCard(a,b,c) then
      return false
   end
   if not isSameSuit(a,b,c) then
      return false
   end
   local ranks = {getRank(a,b,c)}
   table.sort(ranks)

   if ranks[1] == ranks[2] -1 and ranks[2] == ranks[3] - 1 then
      return true
   else
      return false;
   end
end


function clsQZMJ:ctor()
   self.playerCards = {}
   self.playerSize = 2
   self.remainingCards = {}
   self.currentCard = nil
   self.gold = nil
   self.config = config
end

function clsQZMJ:init(config)
   self.config = config
   --TODO check config
   return true
end

function clsQZMJ:start()
   --洗牌
   self.remainingCards = shuffle(clone(CARD))
   
   --发牌
   for i = 1,self.playerSize do
      self.playerCards[i] = {}

      self.playerCards[i].hand = {}
      self.playerCards[i].destop = {}
      self.playerCards[i].disCard = {}

      self.playerCards[i].destop[1] = {
         type = "flowers",
         cards = {}
      }
      self.playerCards[i].destop[2] = {
         type = "disCard",
         cards = {}
      } 
      --第一张牌当金
      self.gold = self.remainingCards[1]

      for k,v in pairs(self.remainingCards) do
         if v == self.gold then
            self.remainingCards[k] = 'O'
         end
      end

      for j = 1,PLAYER_CARD_NUM,1 do
         self:dealCard(i)
      end       
   end  

   --庄家多发牌
   self:dealCard(1)
   self:updateToClinet()

   return true
end

function clsQZMJ:remainingCount()
   return #self.remainingCards
end

function clsQZMJ:dealCard(index)
   local handCards = self.playerCards[index].hand

   local newCard = self.remainingCards[#self.remainingCards]
   self.remainingCards[#self.remainingCards] = nil

   if handCards[newCard] == nil or handCards[newCard] == 0 then
      handCards[newCard] = 1
   else
      handCards[newCard] = handCards[newCard] + 1
   end
end


function clsQZMJ:disCard(index,card)
   local handCards = self.playerCards[index].hand
   if handCards[card] == nil or handCards[card] == 0 then
      return false
   end

   handCards[card] = handCards[card] - 1

   self.currentCard = card

   return true
end

--补花
function clsQZMJ:replaceFlower(index)
   if not self:canReplaceFlower(index) then
      print("error in clsQZMJ:replaceFlower",index)
      return false
   end
   local handCards = self.playerCards[index].hand
   local destopCards = self.playerCards[index].destop
   local flowers = nil

   for k,v in pairs(destopCards) do
      if v.type == "flowers" then
         flowers = v
         break
      end
   end 
   assert(flowers ~= nil)
   for k,v in pairs(CARD_FLOWER) do
      if handCards[v] ~= nil then
         handCards[v] = nil
         flowers.cards[#flowers.cards + 1] = v
      end
   end
   return true
end
--吃牌
function clsQZMJ:chow(index,a,b)
   if not self:canChow(index) then
      print("error in clsQZMJ:chow",index)
      return false
   end
   local handCards = self.playerCards[index].hand
   local destopCards = self.playerCards[index].destop
   
   assert(handCards[a] > 0)
   assert(handCards[b] > 0)
   assert(isSequence(a,b,self.currentCard))
   handCards[a] = handCards[a] - 1
   handCards[b] = handCards[b] - 1

   destopCards[#destopCards + 1] = {
         type = "chow",
         cards = {a,b,self.currentCard}
      }
   return true
end

--碰牌
function clsQZMJ:peng(index)
   if not self:canPeng(index) then
      print("error in clsQZMJ:peng",index)
      return false
   end

   local handCards = self.playerCards[index].hand
   local destopCards = self.playerCards[index].destop

   assert(handCards[self.currentCard] >= 2)
   handCards[self.currentCard] = handCards[self.currentCard] - 2

   destopCards[#destopCards + 1] = {
      type = "pong",
      card = self.currentCard
   }

   return true   
end
--明杠
function clsQZMJ:exposedKong(index)
   if not self:canExposedKong(index) then
      print("error in clsQZMJ:exposedKong",index)
      return false
   end
   local handCards = self.playerCards[index].hand
   local destopCards = self.playerCards[index].destop
   
   if handCards[self.currentCard] == 3 then
      handCards[self.currentCard] = 0

      destopCards[#destopCards + 1] = {
         type = "kong",
         card = self.currentCard
      }
      return true
   else
      for i,j in ipairs(destopCards) do
         if j.type == "pong" and j.card == self.currentCard then
            j.type = "kong"
            return true
         end
      end
   end   
   return false 
end

--暗杠
function clsQZMJ:concealedKong(index,lastCard)
   local handCards = self.playerCards[index].hand


end



function clsQZMJ:win(index)

end

function clsQZMJ:canReplaceFlower(index)
   local handCards = self.playerCards[index].hand
  
   for k,v in pairs(CARD_FLOWER) do
      if handCards[v] ~= nil then
         return true
      end
   end
   return false
end

function clsQZMJ:canPeng(index)
   local handCards = self.playerCards[index].hand
   
   return handCards[self.currentCard] ~= nil and handCards[self.currentCard] >= 2
end

function clsQZMJ:canChow(index)
   local handCards = self.playerCards[index].hand
  
   return handCards[a] ~= nil and handCards[a] > 0 
       and handCards[b] ~= nil and handCards[b] > 0 
       and isSequence(a,b,self.currentCard)
end
function clsQZMJ:canExposedKong(index)
   local handCards = self.playerCards[index].hand
   local destopCards = self.playerCards[index].destop
   
   if handCards[self.currentCard] == 3 then
      return true
   else
      for i,j in ipairs(destopCards) do
         if j.type == "pong" and j.card == self.currentCard then
            return true
         end
      end
   end   
   return false
end
function clsQZMJ:canConcealedKong(index,lastCard)
   local handCards = self.playerCards[index].hand

end

function clsQZMJ:isWin(index,lastCard)
   local cards = self.playerCards[index].hand

   local goldCount = dct[self.gold] or 0

   local function isInSet(s,set)
      for k,v in pairs(set) do
         if string.find(v,s) ~= nil then
            return true
         else
            local offset = 0
            for i = 1,#s do
               offset,_ =  string.find(v,string.sub(s,i,i),offset + 1)
               if offset == nil then
                  break
               end
            end
            if offset ~= nil then
               return true
            end
         end
      end
      return false
   end

   --没有金 牌形 AAAC
   --一个金 牌形 AAAB(游金) AACC AACD AAAF
   --两个金 牌形 AAAA(游金) AABC(游金) AABD(游金) ACCC ACDD ACCD AAAE AACF AADF AACG AAAH
   --三个金 剩余13张牌形 AAAB AACC AADD AAAF(游金) 其他三金倒  
   local function isValidQueue(queue,goldCount)
      table.sort(queue)
      local s = ""
      for i,j in pairs(queue) do
         s = s .. j
      end
      if goldCount == 0 then
         return isInSet(s,{'AAAC'})
      elseif goldCount == 1 then
         return isInSet(s,{'AAAB','AACC','AACD','AAAF'})
      elseif goldCount == 2 then
         return isInSet(s,{'AAAA','AABC','AABD','ACCC','ACDD','ACCD','AAAE','AACF','AADF','AACG'})
      end
   end
   local res = {}

   local typeH = getHonorsType(dct)
   res[#res + 1] = typeH
   if not isValidQueue(res,goldCount) then
      return false
   end

   local typeW = getSuitsTypeWithSuit(dct,'W')
   res[#res + 1] = typeW
   if not isValidQueue(res,goldCount) then
      return false
   end
   local typeT = getSuitsTypeWithSuit(dct,'T')
   res[#res + 1] = typeT

   if not isValidQueue(res,goldCount) then
      return false
   end

   local typeS = getSuitsTypeWithSuit(dct,'S')
   res[#res + 1] = typeS

   return isValidQueue(res,goldCount)

end