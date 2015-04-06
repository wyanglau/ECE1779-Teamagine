package DAO;

import models.Event;
import models.Peeps;

import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.google.appengine.api.datastore.Key;

public class MemcacheOperator {

	private MemcacheService ms;

	public MemcacheOperator() {

		ms = MemcacheServiceFactory.getMemcacheService();
	}

	public void writeEventToMemcache(Key key, Event givenEvent) {

		ms.put(key, givenEvent);

	}

	public Object get(Key key) {

		return ms.get(key);

	}

	public void writeEventPeepsToMemcache(Key key, Peeps peeps) {
		MemcacheService ms = MemcacheServiceFactory.getMemcacheService();

		String peepsKey = MemcacheOperator.parsePeepsKey(key);

		ms.put(peepsKey, peeps);

	}

	public static String parsePeepsKey(Key key) {
		return "peeps_" + key.getId();
	}
}
