import asyncio
import json
from database import categories_col

async def seed_categories():
    with open("seed.json") as f:
        data = json.load(f)
    categories = data["categories"]

    # Optional: clear existing categories first
    await categories_col.delete_many({})

    # Insert each category
    for cat in categories:
        await categories_col.insert_one(cat)

    print("Categories seeded!")

# Run the async function
asyncio.run(seed_categories())
