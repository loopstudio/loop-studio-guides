# CSS guidelines

## When to grid when to flex

When it comes to styling our web apps the layout should be defined using flexbox or grid, the former should be used to define how single line layouts should be ordered and the latest for those layouts that have two dimensions to consider for.

So for layouts like:

```
___________________________________
|                Header            |
|__________________________________|
|       |                          |
| aside |                          |
|       |          main            |
|       |                          |
|_______|__________________________|
|               footer             |
|__________________________________|
```

OR

```
_______________________________
|        title      |          |
|___________________|  image   |
|      description  |          |
|                   |__________|
|                   |   price  |
|___________________|__________|
|        add to cart           |
|______________________________|
```

You should opt for **grid**.

But when you have layouts like:

```
_______________________________
| icon | dropdown |   | button |
|______|__________|___|________|
```

You should opt for **flexbox**.

One thing to consider is the fact that grid is focus on the container and that is space is respected, while flexbox is content first, so this means that the container will adapt to what you put in it.
