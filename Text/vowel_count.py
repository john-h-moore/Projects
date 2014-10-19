import string

def countVowels(s):
    vowels = ['a', 'e', 'i', 'o', 'u']
    vowelCount = {}
    for v in vowels:
        vowelCount[v] = string.count(s, v)
    return vowelCount

def formatOutput(vCount):
    formatted = '%d' %sum(vCount.values())
    for k in sorted(vCount.keys()):
        formatted += '\n\t%s: %d' %(k, vCount[k])
    return formatted


if __name__ == '__main__':
    toCount = raw_input('Type some text and I\'ll count the vowels: ')
    print formatOutput(countVowels(toCount))