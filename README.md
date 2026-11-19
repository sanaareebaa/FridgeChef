# FridgeChef 

**FridgeChef** is a full-stack Java web application designed to help users manage their refrigerator inventory, track ingredient expiry dates, discover recipes based on what they currently have in stock, and reduce food waste. The platform also includes administrative tools for user and recipe management.

---

## Features

* **Smart Inventory Management:** Add, edit, and categorize food items with quantity tracking, units, and expiry dates.
* **Expiry Alerts:** Visual status indicators on the dashboard for fresh stock, items expiring within 3 days, and expired ingredients.
* **Smart Recipe Matching:** Filter recipes by cuisine and meal type. The app automatically cross-references your fridge inventory with recipe requirements to highlight what you can cook right away and list missing ingredients.
* **Saved Favourites:** Bookmark and manage your favourite recipes for quick access.
* **Admin Dashboard:** Manage registered users, monitor platform-wide statistics, add/edit/delete recipes, and highlight a featured "Recipe of the Week".

---

## Tech Stack

* **Frontend:** HTML5, CSS3 (custom design system with glassmorphism cards and animated background blobs), JavaScript
* **Backend:** Java Servlets, JavaServer Pages (JSP)
* **Database:** Apache Derby (`jdbc:derby://localhost:1527/users`), JDBC
* **Icons & Fonts:** FontAwesome 6.4.0, Google Fonts 

---

## Project Structure

```text
FridgeChef/
│
├── src/java/                  # Backend Java Servlets
│   ├── LoginServlet.java          # User & admin authentication
│   ├── RegisterServlet.java       # New user registration
│   ├── AddIngredientServlet.java  # Adds new items to fridge inventory
│   ├── EditIngredientServlet.java # Updates existing fridge items
│   ├── FavouriteServlet.java      # Adds/removes saved recipes
│   └── AdminRecipeServlet.java    # Admin CRUD for recipes & user removal
│
└── web/                       # Frontend JSP Views & Assets
    ├── fridgechef.css             # Shared global stylesheet
    ├── login.jsp                  # Sign-in page
    ├── register.jsp               # Account registration page
    ├── dashboard.jsp              # User overview & expiry stats
    ├── addIngredient.jsp          # Add inventory item form
    ├── editIngredient.jsp         # Edit inventory item form
    ├── viewIngredients.jsp        # Full digital fridge view
    ├── recipes.jsp                # Recipe discovery & ingredient matching
    ├── recipeDetail.jsp           # Step-by-step recipe instructions
    ├── favourites.jsp             # Saved recipes list
    ├── adminDashboard.jsp         # Admin overview
    ├── adminRecipes.jsp           # Admin recipe manager
    ├── editRecipe.jsp             # Admin recipe editor
    ├── adminUsers.jsp             # Admin user manager & insights
    └── logout.jsp                 # Session termination
