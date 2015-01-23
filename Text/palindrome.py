import re

def isPalindrome(s):
	s = re.sub('[^A-Za-z0-9]+', '', s).lower()
	isPalindrome = True
	for i in range(0, len(s)/2):
		isPalindrome = isPalindrome and (s[i] == s[len(s)-1-i])
	return isPalindrome