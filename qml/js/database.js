.pragma library

var idDatabase = function(name, desc, size){
	var versionCONST = "1.0";
	var TABLE_PREFIX = "together";

	var db = openDatabaseSync(name, "", desc, size);

	this.Table = function(tname){
		return TABLE_PREFIX !== "" ? TABLE_PREFIX + "_" + tname : tname;
	}

	this.Create = function(name, targs){
		var tname = TABLE_PREFIX !== "" ? TABLE_PREFIX + "_" + name : name;
		if (db.version !== versionCONST){
			var change = function (ta){
				ta.executeSql('DROP TABLE IF EXISTS %1'.arg(tname));
				ta.executeSql('CREATE TABLE IF NOT EXISTS %1 %2'.arg(tname).arg(targs));
			}
			db.changeVersion(db.version, versionCONST, change);
		} else {
			var trans = function(ta){
				ta.executeSql('CREATE TABLE IF NOT EXISTS %1 %2'.arg(tname).arg(targs));
			}
			db.transaction(trans);
		}
	}

	this.Insert = function(tname, argv){
		var proto = [];
		for(var i in argv){
			proto.push('?');
		}
		db.transaction(function(ta){
			ta.executeSql('INSERT OR REPLACE INTO %1 VALUES (%2)'.arg(tname).arg(proto.join(',')), argv);
		});
	}

	this.Select = function(tname, model, where, order){
		var push = Array.isArray(model) ? "push" : "append";
		var w = this.__Where(where);
		var o = this.__Order(order);
		db.readTransaction(function(ta){
			var sql = 'SELECT * FROM %1'.arg(tname);
			if(w) sql += " where " + w;
			if(o) sql += " order " + o;
			var rd = ta.executeSql(sql);
			for (var i = rd.rows.length - 1; i >= 0; i --){
				var item = rd.rows.item(i);
				model[push](item);
			}
		});
	}

	this.Exists = function(tname, tkey, tvalue){
		var rd;
		db.readTransaction(function(ta){
			try{
				rd = ta.executeSql('SELECT %1 FROM %2 WHERE %3 = %4'.arg(tkey).arg(tname).arg(tkey).arg(tvalue)).rows.length;
			}catch(e){
				rd = 0;
			}
		});
		return rd !== 0;
	}

	this.Delete = function(tname, tkey, tvalue){
		db.transaction(function(ta){
			ta.executeSql('DELETE FROM %1 WHERE %2 = %3'.arg(tname).arg(tkey).arg(tvalue));
		});
	}

	this.Drop = function(tname){
		db.transaction(function(ta){
			ta.executeSql('DELETE FROM %1'.arg(tname));
		});
	}

	this.Count = function(tname, where){
		var rd = 0;
		var rs;
		var w = this.__Where(where);
		db.readTransaction(function(tx){
			try{
				var sql = 'SELECT COUNT(1) AS \'_Count\' FROM %1'.arg(tname);
				if(w) sql += " where " + w;
				rs = tx.executeSql(sql);
				if(rs.rows.length === 1)
					rd = rs.rows.item(0)._Count;
			}catch(e){
				rd = 0;
			}
		});
		return rd;
	},

	this.__Where = function(where){
		var t = typeof(where);
		if(t === "string")
			return where;
		else if(t === "object")
		{
			if(Array.isArray(where))
				return where.join(" AND ");
			else
			{
				var arr = [];
				for(var k in where)
				{
					arr.push(k + "=" + where[k]);
				}
				return arr.join(" AND ");
			}
		}
		return "";
	},

	this.__Order = function(order){
		var t = typeof(order);
		if(t === "string")
			return order;
		else if(t === "object")
		{
			if(Array.isArray(order))
				return order.join(",");
			else
			{
				var arr = [];
				for(var k in order)
				{
					arr.push(k + " " + order[k]);
				}
				return arr.join(",");
			}
		}
		return "";
	},
}
