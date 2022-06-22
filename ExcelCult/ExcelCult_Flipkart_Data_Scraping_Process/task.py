"""
   Challenge #6 from excelcult.com Flipkart Data Scraping
   Process. Goal is to open Flipkart page and search for product.
   From first page of results for all products model, colour and price
   needs to be saved to csv file. Result csv file will be sent to
   email
"""
from RPA.Browser.Playwright import Playwright
from RPA.Tables import Tables
import time

browser_lib = Playwright()
table_lib = Tables()
result_table = table_lib.create_table()
result_table._add_column('Model')
result_table._add_column('Colour')
result_table._add_column('Price')

def create_browser():
    browser_lib.new_browser(headless=False)
    browser_lib.new_context(viewport={'width': 900, 'height': 720})

def search_for_product(product_name):
    browser_lib.new_page(f'https://www.flipkart.com/search?q={product_name}')
def get_results_from_page():
    """Reads results from current page, extracts colour,
       model and price. Adds found information to resutls
       table"""
    browser_lib.wait_for_elements_state('._5THWM1',timeout=15)
    found_elements = browser_lib.get_elements('._4ddWXP')
    for element in found_elements:
        colour = browser_lib.get_property(element + '>> ._3Djpdu',property='textContent')
        model = browser_lib.get_property(element + '>> .s1Q9rs',property='title')
        price = browser_lib.get_property(element + '>> ._30jeq3',property='textContent')
        table_lib.add_table_row(result_table,{'Model':model,'Colour':colour,'Price':price})
        #print(f"Colour: {colour}, Model: {model}, Price: {price}")
def save_result_to_csv():
    table_lib.write_table_to_csv(result_table,'output/search_results.csv',encoding="utf-8")
def minimal_task():
    create_browser()
    search_for_product('pendrive')
    get_results_from_page()
    save_result_to_csv()
    print("Done.")


if __name__ == "__main__":
    minimal_task()