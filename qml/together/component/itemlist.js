var __items = [];

function Clear(i)
{
	if(i === undefined)
	{
		var r = 0;
		try{
			for(var i in __items)
			{
				var item = __items[i];
				item.visible = false;
				item.destroy();
				r++;
			}
			__items = [];
			return r;
		}
		catch(e)
		{
			console.log(e.message);
			return r;
		}
	}
	else
	{
		var index = i < 0 ? __items.length + i : i;
		try{
			var item = __items.splice(index, 1);
			item.visible = false;
			item.destroy();
			return true;
		}
		catch(e)
		{
			console.log(e.message);
			return false;
		}
	}
}

function Pop()
{
	Destroy(-1);
}

function Push(item)
{
	__items.push(item);
}

function Count()
{
	return __items.length;
}

function Get(i)
{
	if(i === undefined)
	{
		return __items;
	}
	else
	{
		var index = i < 0 ? __items.length + i : i;
		return __items[index];
	}
}

function Foreach(func)
{
	for(var i in __items)
	{
		if(func(__items[i], i) === false)
			break;
	}
}
