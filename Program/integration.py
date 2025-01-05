import pandas as pd
import random
import sys
import math

class Integration():

    def __init__(self, dataset:pd.DataFrame, x_col:str, y_col:str):
        self.dataset = dataset
        self.maximum_y = max(dataset[y_col])
        self.x_col = x_col
        self.y_col = y_col

    
    def get_area(self, technique:str, start_x:int, end_x:int, points:int = 1000):
        if not ((end_x < start_x) and (start_x in self.dataset[self.x_col] and end_x in self.dataset[self.x_col])):
            mini = min(self.dataset[self.x_col])
            maxi = max(self.dataset[self.x_col])
            sys.exit(ValueError(f"Not in the good interval [{mini},{maxi}]"))
        if technique == "Monte Carlo":
            if points <= 0:
                sys.exit(ValueError("Invalid inputs"))
            return self.area_monteCarlo(start_x,end_x,points)
        elif technique == "Trapezoid":
            return self.area_trapezoid(start_x,end_x)
        else:
            sys.exit(ValueError("Invalid intergration techniques"))
    
    def area_monteCarlo(self, start_x:int, end_x:int, points:int):
        under = 0
        for _ in range(points):
            coor = (start_x + random.random() * (end_x - start_x), random.random() * self.maximum_y)
            fx = self.linear_interpolate(coor)

            under += 1 if coor[1] <= fx else 0
        
        return under / points * (end_x - start_x)
    
    def area_trapezoid(self, start_x:int, end_x:int):
        get = self.dataset.loc[self.dataset[self.x_col] == start_x]
        start_y = get[self.y_col]

        get = self.dataset.loc[self.dataset[self.x_col] == end_x]
        end_y = get[self.y_col]

        return (start_y + end_y) / 2 * (end_x - start_x)
                

    def linear_interpolate(self, coor:tuple):
        x = coor[0]

        lower_x = math.floor(x)
        get = self.dataset.loc[self.dataset[self.x_col] == lower_x]
        lower_y = get[self.y_col]

        upper_x = math.ceil(x)
        get = self.dataset.loc[self.dataset[self.x_col] == upper_x]
        upper_y = get[self.y_col]

        y = lower_y + (x - upper_x) * upper_y

        return y

            
            
