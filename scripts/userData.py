__author__="Andrea Fassina"
__date__ ="$14-Dec-2013 11:50:49$"

import pprint
import hashlib
import json
import random

class UserOperations():
    """Populates user information then saves output to JSON."""

    def __init__(self):
        """Loads ingredients and cuisines in class variables."""
        ing = self.readJSON("ingredients.json")
        cuis = self.readJSON("cuisines.json")
        self.ingredients = ing['ingredients']
        self.cuisines = cuis['cuisines']

    def populateUserData(self, jsonData = {}):
        """Populates one user object.

        :param jsonData:
            Holds objects containing user data, dict.
            
        Return object with populated information for users.
        """
        for key in jsonData:
            for user in jsonData[key]:
                uid = jsonData[key][user]
                 #Generate user image
                try:
                    uid['img'] = self.generateUserImage(uid['email'])
                except Exception as e:
                    print "[populateUserData] Error in creating user images"
                #Generate allowed excluded ingredients and cuisines
                try:
                    uid['allowedIngredients'], uid['excludedIngredients'] = self.generateTaste(self.ingredients)
                    uid['allowedCuisine'], uid['excludedCuisine'] = self.generateTaste(self.cuisines)
                except Exception as e:
                    print "[populateUserData] Error in generating taste %s" % e
        return jsonData

    def generateUserImage(self, email = "an@address.com", imgPrefix = "http://www.gravatar.com/avatar/"):
        """Generates user images from Gravatar.

        :param email:
            Email address to generate hash from, string.

        :param imgPrefix:
            Text to prepend to hash of email, string.

        Return string with img Gravatar url.
        """
        try:
            hash = self.__hashSentence(email)
            img =  imgPrefix + str(hash) + ".jpg"
        except Exception as e:
            print "[generateUserImages] Error in creating user images"
        return img
  
    def generateTaste(self, listOfItems, num = 7, key = ['searchValue']):
        """Populates ingredients

        :param listOfItems:
            Contains all dicts to extract random from, list.

        :param num:
            How many elements to pull from listOfItems, int.

        :param key:
            Which key to extract from the objects in listOfItems, list.

        Return two lists, allowed and excluded, with randomized objects.
        """
        assignedNum = []
        assigned = []
        for i in range(num):
            ingNum = random.randint(0, len(listOfItems))
            if ingNum not in (assignedNum):
                assignedNum.append(ingNum)
                try:
                    assigned.append(listOfItems[ingNum][key[0]])
                except:
                    assigned.append(listOfItems[ingNum][key[1]])
        allowed = assigned[:(num/2)]
        excluded = assigned[(num/2):]
        return allowed, excluded

    def __hashSentence(self, sent = "Any sentence would do here!", hashLength = 16):
        """Generates MD5 hash for sentence

        :param sent:
            Text to generate hash from, string.

        :param hashLength:
            Max length of generated hash, int.

        Return hex int with sent hash.
        """
        hash = hashlib.md5(sent).hexdigest()
        return hash

    def readJSON(self, fileName):
        """Read JSON file

        :param fileName:
            Json to read, string.
            
        Return object with read JSON information.
        """
        openedFile=open(fileName)
        jsonData= json.loads(openedFile.read())
        openedFile.close()
        return jsonData

    def saveJSON(self, fileName, data):
        """Save JSON file

        :param fileName:
            JSON to save, string.
        
        Return string with created json file name.
        """
        f = open(fileName, 'w')
        jsonData = json.dumps(data, sort_keys=True, indent=4)
        f.write(jsonData)
        f.close()
        return fileName

def main():
    userop = UserOperations()
    jd1 = userop.readJSON(fileName = "userData.json")
    jd = userop.populateUserData(jd1)
    fn = userop.saveJSON("output.json", jd)
    pprint.pprint(jd)


if __name__ == "__main__":
   main()
