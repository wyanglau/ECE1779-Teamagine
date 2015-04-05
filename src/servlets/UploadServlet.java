package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.Event;
import DAO.Constants_EventInfo;
import DAO.Constants_EventPeeps;
import DAO.Constants_General;
import DAO.DatastoreWriter;
import DAO.MemcacheWriter;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;

/**
 * Servlet implementation class UploadServlet
 */
public class UploadServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public UploadServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		PrintWriter out = resp.getWriter();
		try {
			// get parameters from page information
			String creator = (String) req.getParameter("creator");
			String title = (String) req.getParameter("create_title");
			String category = (String) req.getParameter("create_category");
			String ca = (String) req.getParameter("create_capacity");
			String sdt = (String) req.getParameter("create_from");
			String edt = (String) req.getParameter("create_to");
			String location = (String) req.getParameter("create_location");
			String contact = (String) req.getParameter("create_contact");
			String description = (String) req
					.getParameter("create_description");

			// Initialize DatastoreWriter and MemcacheWriter
			DatastoreWriter DSW = new DatastoreWriter();
			MemcacheWriter MCW = new MemcacheWriter();

			// Parse information into correct format
			long capacity = Long.parseLong(ca);

			Date startDateTime = null;
			Date endDateTime = null;
			sdt = sdt.replace(' ', 'T');
			edt = edt.replace(' ', 'T');

			startDateTime = new SimpleDateFormat("yyyy-MM-dd\'T\'HH:mm")
					.parse(sdt);
			endDateTime = new SimpleDateFormat("yyyy-MM-dd\'T\'HH:mm")
					.parse(edt);

			// build the event information entity object and save it into the
			// data
			// store
			Entity eventEntity = new Entity(Constants_EventInfo.TABLENAME);
			eventEntity.setProperty(Constants_EventInfo.EVENTCREATOR, creator);
			eventEntity.setProperty(Constants_EventInfo.EVENTTITLE, title);
			eventEntity
					.setProperty(Constants_EventInfo.EVENTCATEGORY, category);
			eventEntity
					.setProperty(Constants_EventInfo.EVENTCAPACITY, capacity);
			eventEntity.setProperty(Constants_EventInfo.EVENTSTARTDATETIME,
					startDateTime);
			eventEntity.setProperty(Constants_EventInfo.EVENTENDDATETIME,
					endDateTime);
			eventEntity
					.setProperty(Constants_EventInfo.EVENTLOCATION, location);
			eventEntity.setProperty(Constants_EventInfo.EVENTCONTACT, contact);
			eventEntity.setProperty(Constants_EventInfo.EVENTDESCRIPTION,
					description);

			// Set DatastoreWriter entity to event info entity and write to data
			// store
			Key eventKey = DSW.writeToDatastoreAndRetrieveKey(eventEntity);

			// Parse event key into ID
			long eventID = eventKey.getId();

			// Initialize peeps list by adding creator to it
			List<String> eventMembers = new ArrayList<String>();
			eventMembers.add(creator);

			// build the event peeps entity object and save it into the data
			// store
			Entity peepsEntity = new Entity(Constants_EventPeeps.TABLENAME);
			peepsEntity.setProperty(Constants_EventPeeps.EVENTID, eventID);
			peepsEntity.setProperty(Constants_EventPeeps.EVENTMEMBERS,
					eventMembers);

			// Set DatastoreWriter entity to event info entity and write to data
			// store
			DSW.writeToDatastoreAndRetrieveKey(peepsEntity);

			// Create Event object
			Event createdEvent = new Event();
			createdEvent.fromKeyAndEntity(eventKey, eventEntity);

			// Write new event and its peeps list into mem cache
			MCW.writeEventToMemcache(eventKey, createdEvent);
			MCW.writeEventPeepsToMemcache(eventKey, peepsEntity);

			out.print(Constants_General.SUCCESS);
		} catch (Exception e) {
			e.printStackTrace();
			out.print(e.getMessage());
		}

	}

}
