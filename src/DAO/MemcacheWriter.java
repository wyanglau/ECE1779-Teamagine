package DAO;


import models.Event;

import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.google.appengine.api.datastore.Key;

public class MemcacheWriter {

	public MemcacheWriter ()
	{
	}
	
	public void writeEventToMemcache (Key key, Event givenEvent)
	{
		MemcacheService ms = MemcacheServiceFactory.getMemcacheService();
		
		ms.put(key, givenEvent);

	}
}

