import unirest, urllib2, json, codecs, re, string, random, time

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

with open ('missed_in_website_guess.txt', 'r') as read_file:
    food = read_file.read().split('\n')

no_url = []
for line in food:
    no_url.append(line.split('\t'))

right_file = open('selenium_caught.txt', 'w')
wrong_file = open('selenium_missed.txt', 'w')

driver = webdriver.Firefox()

driver.get("http://www.google.com")

really_nothing = []

for unfound in no_url:
    rec = unfound[0]
    state = unfound[2]
    name = unfound[1]

    try:
        search_string = name + ' ' + state + ' site:alltrails.com'
        inputElement = driver.find_element_by_name("q")
        inputElement.send_keys(search_string)
        inputElement.submit()
        print driver.title
        WebDriverWait(driver,20).until(EC.title_contains(name))
        print driver.title
        elem = driver.find_element_by_xpath("//h3[@class='r']/a")
        att = elem.get_attribute("href")
        print "Website: ", att
        line = rec + '\t' + att + '\n'
        with open('selenium_caught.txt', 'a') as app_file:
            app_file.write(line)

        wait_time = random.randint(0,30)
        print "Wait time: ", wait_time
        time.sleep(wait_time)
        if wait_time%2 == 0:
            elem.click()
            time.sleep((wait_time/2))
        driver.get("http://www.google.com")
        inputElement = driver.find_element_by_name("q")
    except:
        print "Unable to find a search"
        really_nothing.append(unfound)
        try:
            line = rec + '\t' + name + '\t' + state + '\n'
            with open('selenium_missed.txt', 'a') as app_file:
                app_file.write(line)
        except:
            line = rec + '\t' + '\t' + '\n'
            with open('selenium_missed.txt', 'a') as app_file:
                app_file.write(line)

        wait_time = random.randint(0,30)
        print "Wait time: ", wait_time
        time.sleep(wait_time)
        driver.get("http://www.google.com")

driver.quit()

