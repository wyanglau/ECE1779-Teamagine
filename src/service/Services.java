package service;

import java.io.UnsupportedEncodingException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import models.Event;
import models.Peeps;
import DAO.Constants_EventInfo;
import DAO.Constants_EventPeeps;
import DAO.Constants_General;
import DAO.MemcacheOperator;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Query.SortDirection;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserServiceFactory;

public class Services {

	/**
	 * Set params to null to get all events
	 * 
	 * @param dateFilter
	 * @param capacityFilter
	 * @param categoryFilter
	 * @return
	 */
	public static Map<String, List<Event>> retrieveAllEvents(String dateFilter,
			String capacityFilter, String categoryFilter) {

		// Get only keys from datastore
		List<Key> keys = retrieveAllEventKeys(Constants_EventInfo.TABLENAME,
				dateFilter, capacityFilter, categoryFilter);

		// Pull entities from memcache, and the others from datastore
		List<Event> allEvents = retrieveExpectedEvents(keys,
				Constants_EventInfo.TABLENAME);

		// seperate them into two groups, 1 of joined events and 1 for the
		// others.
		User user = UserServiceFactory.getUserService().getCurrentUser();
		String email = user.getEmail();
		List<Long> joinedID = new LinkedList<Long>();
		List<Long> availableID = new LinkedList<Long>();

		List<Peeps> peeps = retrieveAllPeeps();

		for (Peeps p : peeps) {
			List<String> emails = p.getPeeps();
			if ((emails != null) && emails.contains(email)) {
				joinedID.add(p.getId());
			} else {
				availableID.add(p.getId());
			}
		}

		List<Event> joined = new LinkedList<Event>();
		List<Event> available = new LinkedList<Event>();

		for (Event e : allEvents) {

			if (joinedID.contains(e.getKey().getId())) {
				joined.add(e);
			} else {
				available.add(e);
			}
		}

		Map<String, List<Event>> result = new HashMap<String, List<Event>>();

		result.put(Constants_General.AVAILABLE_EVENTS, available);
		result.put(Constants_General.JOINED_EVENTS, joined);

		return result;

	}

	public static List<Peeps> retrieveAllPeeps() {

		List<Peeps> peeps = new LinkedList<Peeps>();

		Query query = new Query(Constants_EventPeeps.TABLENAME);
		DatastoreService ds = DatastoreServiceFactory.getDatastoreService();

		PreparedQuery result = ds.prepare(query);

		for (Entity e : result.asIterable()) {

			peeps.add(new Peeps().fromEntityAndKey(
					(long) e.getProperty(Constants_EventPeeps.EVENTID), e));

		}

		return peeps;

	}

	public static List<Event> retrieveHostersEvents() {

		List<Event> own = new LinkedList<Event>();
		List<Key> keys = retrieveAllEventKeys(Constants_EventInfo.TABLENAME,
				null, null, null);

		List<Event> allEvents = retrieveExpectedEvents(keys,
				Constants_EventInfo.TABLENAME);

		User user = UserServiceFactory.getUserService().getCurrentUser();
		String email = user.getEmail();

		for (Event e : allEvents) {
			if (e.getCreator().equals(email)) {
				own.add(e);
			}
		}
		return own;
	}

	/**
	 * 1. check memcache 2. check datastore
	 * 
	 * @param keys
	 * @param table
	 * @return
	 */
	private static List<Event> retrieveExpectedEvents(List<Key> keys,
			String table) {
		List<Key> nonExistedInMemCache = new LinkedList<Key>();

		List<Event> events = new LinkedList<Event>();
		MemcacheService s = MemcacheServiceFactory.getMemcacheService();

		for (Key key : keys) {

			if (s.contains(key)) {
				events.add((Event) s.get(key));
			} else {
				nonExistedInMemCache.add(key);
			}
		}

		if (nonExistedInMemCache.size() != 0) {
			events.addAll(retrieveEntitiesFromDataStore(nonExistedInMemCache,
					table));
		}
		return events;

	}

	private static List<Event> retrieveEntitiesFromDataStore(List<Key> keys,
			String table) {

		List<Event> events = new LinkedList<Event>();
		DatastoreService service = DatastoreServiceFactory
				.getDatastoreService();

		for (Entity e : service.get(keys).values()) {
			events.add(new Event().fromKeyAndEntity(e.getKey(), e));
		}

		return events;

	}

	private static List<Key> retrieveAllEventKeys(String table,
			String dateFilter, String capacityFilter, String categoryFilter) {

		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		Query query = new Query(table).setKeysOnly();
		setFilter(query, table, dateFilter, capacityFilter, categoryFilter);
		PreparedQuery result = datastore.prepare(query);

		List<Key> keys = new LinkedList<Key>();
		for (Entity e : result.asIterable()) {
			keys.add(e.getKey());
		}
		return keys;

	}

	private static void setFilter(Query query, String table, String dateFilter,
			String capacityFilter, String categoryFilter) {
		if (categoryFilter != null) {
			if (categoryFilter.equals(Constants_General.FILTER_OTHERS)) {

				Filter f1 = new FilterPredicate(
						Constants_EventInfo.EVENTCATEGORY,
						Query.FilterOperator.NOT_EQUAL,
						Constants_General.FILTER_CATEGORY_SPORT.toLowerCase());
				Filter f2 = new FilterPredicate(
						Constants_EventInfo.EVENTCATEGORY,
						Query.FilterOperator.NOT_EQUAL,
						Constants_General.FILTER_CATEGORY_PARTY.toLowerCase());

				Filter f3 = new FilterPredicate(
						Constants_EventInfo.EVENTCATEGORY,
						Query.FilterOperator.NOT_EQUAL,
						Constants_General.FILTER_CATEGORY_SEMINAR.toLowerCase());

				query.setFilter(CompositeFilterOperator.and(f1, f2, f3));

			} else {
				query.setFilter(new FilterPredicate(
						Constants_EventInfo.EVENTCATEGORY,
						Query.FilterOperator.EQUAL, categoryFilter
								.toLowerCase()));
			}
		}

		if (capacityFilter != null) {

			long l10 = 10;
			long l20 = 20;
			long l50 = 50;
			Filter capQueryFilter = null;

			switch (capacityFilter) {
			case Constants_General.FILTER_CAPACITY_LESS_THAN_10:
				capQueryFilter = new FilterPredicate(
						Constants_EventInfo.EVENTCAPACITY,
						Query.FilterOperator.LESS_THAN, l10);
				break;
			case Constants_General.FILTER_CAPACITY_LESS_THAN_20: {
				Filter f1 = new FilterPredicate(
						Constants_EventInfo.EVENTCAPACITY,
						Query.FilterOperator.GREATER_THAN_OR_EQUAL, l10);
				Filter f2 = new FilterPredicate(
						Constants_EventInfo.EVENTCAPACITY,
						Query.FilterOperator.LESS_THAN, l20);

				capQueryFilter = CompositeFilterOperator.and(f1, f2);
				break;

			}
			case Constants_General.FILTER_CAPACITY_LESS_THAN_50: {
				Filter f1 = new FilterPredicate(
						Constants_EventInfo.EVENTCAPACITY,
						Query.FilterOperator.GREATER_THAN_OR_EQUAL, l20);
				Filter f2 = new FilterPredicate(
						Constants_EventInfo.EVENTCAPACITY,
						Query.FilterOperator.LESS_THAN, l50);

				capQueryFilter = CompositeFilterOperator.and(f1, f2);
				break;
			}
			case Constants_General.FILTER_CAPACITY_MORE_THAN_50: {

				capQueryFilter = new FilterPredicate(
						Constants_EventInfo.EVENTCAPACITY,
						Query.FilterOperator.GREATER_THAN_OR_EQUAL, l50);
				break;
			}
			default:

				System.out
						.println("[Services] capacity filter invalid. Filter Value ="
								+ capacityFilter);
				break;

			}

			query.setFilter(capQueryFilter);

		}

		if (dateFilter != null) {

			if (dateFilter.equals(Constants_General.SORT_DATE_ASCENDING)) {
				query.addSort(Constants_EventInfo.EVENTSTARTDATETIME,
						SortDirection.ASCENDING);
			} else if (dateFilter
					.equals(Constants_General.SORT_DATE_DESCENDING)) {
				query.addSort(Constants_EventInfo.EVENTSTARTDATETIME,
						SortDirection.DESCENDING);
			}

		}
	}

	public void quitEvent(Key key) throws EntityNotFoundException {
		User user = UserServiceFactory.getUserService().getCurrentUser();
		String email = user.getEmail();

		DatastoreService ds = DatastoreServiceFactory.getDatastoreService();
		Query query = new Query(Constants_EventPeeps.TABLENAME);
		query.setFilter(new FilterPredicate(Constants_EventPeeps.EVENTID,
				Query.FilterOperator.EQUAL, key.getId()));
		Entity peepMembers = ds.prepare(query).asSingleEntity();
		@SuppressWarnings("unchecked")
		List<String> peeps = (List<String>) peepMembers
				.getProperty(Constants_EventPeeps.EVENTMEMBERS);

		peeps.remove(email);
		peepMembers.setProperty(Constants_EventPeeps.EVENTMEMBERS, peeps);
		ds.put(peepMembers);

		MemcacheOperator mcw = new MemcacheOperator();
		mcw.writeEventPeepsToMemcache(key,
				new Peeps().fromEntityAndKey(key.getId(), peepMembers));

	}

	public void joinEvent(Key key) throws EntityNotFoundException {
		User user = UserServiceFactory.getUserService().getCurrentUser();
		String email = user.getEmail();

		DatastoreService ds = DatastoreServiceFactory.getDatastoreService();

		Query query = new Query(Constants_EventPeeps.TABLENAME);
		query.setFilter(new FilterPredicate(Constants_EventPeeps.EVENTID,
				Query.FilterOperator.EQUAL, key.getId()));
		Entity peepMembers = ds.prepare(query).asSingleEntity();

		@SuppressWarnings("unchecked")
		List<String> peeps = (List<String>) peepMembers
				.getProperty(Constants_EventPeeps.EVENTMEMBERS);
		if (peeps == null) {
			peeps = new ArrayList<String>();

		}
		peeps.add(email);
		peepMembers.setProperty(Constants_EventPeeps.EVENTMEMBERS, peeps);
		ds.put(peepMembers);

		MemcacheOperator mcw = new MemcacheOperator();
		mcw.writeEventPeepsToMemcache(key,
				new Peeps().fromEntityAndKey(key.getId(), peepMembers));

		Event event = (Event) mcw.get(key);
		if (event == null) {
			event = new Event().fromKeyAndEntity(key, ds.get(key));
		}

		DateFormat fmt = new SimpleDateFormat("yyyy.mm.dd E HH:mma");
		String content = "<p>Hi " + user.getNickname()
				+ ", wecome to the event!</p>" + "<ul><li>Title:  <strong>"
				+ event.getTitle() + " </strong></li>"
				+ "<li>Category: <strong>" + event.getCategory()
				+ " </strong></li>" + "<li>Start Time: <strong>"
				+ fmt.format(event.getStartDateTime()) + "</strong></li>"
				+ "<li>End Time: <strong>" + fmt.format(event.getEndDateTime())
				+ "</strong></li>" + "<li>Address: <strong>"
				+ event.getLocation() + "</strong></li>"
				+ "<li>Contact: <strong>" + event.getContact()
				+ "</strong></li>" + "</ul><p>Wish you a good time!</p>"
				+ "<br/><p>Sincerely,</p>" + "<p>Ryan, Harris, Ling</p>";

		String subject = "[Teammate Finder] Successfully joined an event.";

		sendNoticingMail(subject, content, email, user.getNickname());
	}

	public void batchMail(String subject, String content,
			List<String> recipients, String name) {

	}

	/**
	 * Send a noticing email
	 * 
	 * @param content
	 *            message
	 * @param recipient
	 *            Email
	 */
	public void sendNoticingMail(String subject, String content,
			String recipients, String nickName) {
		Properties prop = new Properties();
		Session session = Session.getDefaultInstance(prop);
		Message msg = new MimeMessage(session);

		try {
			msg.setFrom(new InternetAddress("wyang.lau@gmail.com",
					"Find a Teammate"));
			msg.addRecipients(Message.RecipientType.BCC,
					InternetAddress.parse(recipients));
			msg.setSubject(subject);
			msg.setContent(content, "text/html;charset = gbk");
			Transport.send(msg);
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (MessagingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}
