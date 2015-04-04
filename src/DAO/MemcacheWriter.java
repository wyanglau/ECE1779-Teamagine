package DAO;


import models.Event;

import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.google.appengine.api.datastore.Entity;
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
	
	public void writeEventPeepsToMemcache (Key key, Entity peepsEntity)
	{
		MemcacheService ms = MemcacheServiceFactory.getMemcacheService();
		
		String peepsKey = MemcacheWriter.parsePeepsKey(key);
		
		ms.put(peepsKey, peepsEntity);

	}

	public static String parsePeepsKey (Key key)
	{
		return "peeps_"+key.getId();
	}
}

