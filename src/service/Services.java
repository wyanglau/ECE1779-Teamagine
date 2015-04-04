package service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import models.Event;
import DAO.Constants_EventInfo;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;

public class Services {

	public Services() {

	}

	public static List<Entity> getAllEvents() {
		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		List<Entity> Event = new ArrayList<Entity>();
		Query query = new Query(Constants_EventInfo.TABLENAME);
		PreparedQuery result = datastore.prepare(query);

		for (Entity event : result.asIterable()) {
			Event.add(event);
		}

		return Event;

	}

	public static List<Event> parse(List<Entity> entities) {

		List<Event> Event = new ArrayList<Event>();

		for (Entity e : entities) {
			Event.add(parse(e));
		}

		return Event;

	}

	public static Event parse(Entity entity) {

		Event event = new Event();
		event.setTitle((String) entity
				.getProperty(Constants_EventInfo.EVENTTITLE));
		event.setCapacity((long) entity
				.getProperty(Constants_EventInfo.EVENTCAPACITY));
		event.setCategory((String) entity
				.getProperty(Constants_EventInfo.EVENTCATEGORY));
		event.setContact((String) entity
				.getProperty(Constants_EventInfo.EVENTCONTACT));
		event.setDescription((String) entity
				.getProperty(Constants_EventInfo.EVENTDESCRIPTION));
		event.setEnd((Date) entity
				.getProperty(Constants_EventInfo.EVENTENDDATETIME));
		event.setStartDateTime((Date) entity
				.getProperty(Constants_EventInfo.EVENTSTARTDATETIME));
		event.setKey(entity.getKey());
		event.setLocation((String) entity
				.getProperty(Constants_EventInfo.EVENTLOCATION));

		return event;

	}
}
