package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.Event;
import service.Services;
import DAO.Constants_EventPeeps;
import DAO.Constants_General;
import DAO.MemcacheOperator;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserServiceFactory;

/**
 * Servlet implementation class AbortEventServlet
 */
public class AbortEventServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public AbortEventServlet() {
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
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		PrintWriter out = response.getWriter();
		try {
			String keyValue = request.getParameter("keystring");
			Key key = KeyFactory.stringToKey(keyValue);

			MemcacheService ms = MemcacheServiceFactory.getMemcacheService();
			ms.delete(key);
			ms.delete(MemcacheOperator.parsePeepsKey(key));

			DatastoreService ds = DatastoreServiceFactory.getDatastoreService();
			Entity entity = ds.get(key);
			Event event = new Event().fromKeyAndEntity(key, entity);
			ds.delete(key);

			Query query = new Query(Constants_EventPeeps.TABLENAME);
			query.setFilter(new FilterPredicate(Constants_EventPeeps.EVENTID,
					Query.FilterOperator.EQUAL, key.getId()));
			Entity result = ds.prepare(query).asSingleEntity();
			ds.delete(result.getKey());

			@SuppressWarnings("unchecked")
			List<String> peeps = (List<String>) result
					.getProperty(Constants_EventPeeps.EVENTMEMBERS);
			if ((peeps != null) && (!peeps.isEmpty())) {
				sendEmail(event, peeps);
			}

			out.print(Constants_General.SUCCESS);

		} catch (Exception e) {
			e.printStackTrace();
			out.print(e.getMessage());

		}

	}

	private void sendEmail(Event event, List<String> peeps) {
		User user = UserServiceFactory.getUserService().getCurrentUser();
		DateFormat fmt = new SimpleDateFormat("yyyy.mm.dd E HH:mma");

		Services s = new Services();
		String subject = "[Teammate Finder] We are sorry to notice that an event has been canceled.";
		String content = "<p>Hi "
				+ ", We are sorry to notice that the following event has been canceled by the host:</p>"
				+ "<ul><li>Title:  <strong>" + event.getTitle()
				+ " </strong></li>" + "<li>Category: <strong>"
				+ event.getCategory() + " </strong></li>"
				+ "<li>Start Time: <strong>"
				+ fmt.format(event.getStartDateTime()) + "</strong></li>"
				+ "<li>End Time: <strong>" + fmt.format(event.getEndDateTime())
				+ "</strong></li>" + "<li>Address: <strong>"
				+ event.getLocation() + "</strong></li>"
				+ "<li>Contact: <strong>" + event.getContact()
				+ "</strong></li>"
				+ "</ul><p>Wish you a good time in rest of your events!</p>"
				+ "<br/><p>Sincerely,</p>" + "<p>Ryan, Harris, Ling</p>";

		String recipients = "";
		for (String r : peeps) {
			recipients += r + ",";
		}
		recipients = recipients.substring(0, recipients.length() - 2);
		s.sendNoticingMail(subject, content, recipients, user.getNickname());
	}
}
