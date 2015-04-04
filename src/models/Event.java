package models;

import java.io.Serializable;
import java.util.Date;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;

import DAO.*;

public class Event implements Serializable
{
	private static final long serialVersionUID = 1L;
	

	private Key key;
	private String creator;
	private String title;
	private String category;
	private long capacity;
	private Date startDateTime;
	private Date endDateTime;
	private String location;
	private String contact;
	private String description;
	
	public Event ()
	{
	}
	
	public void fromKeyAndEntity (Key eventKey, Entity eventEntity)
	{
		this.key = eventKey;
		this.creator = (String) eventEntity.getProperty(Constants_EventInfo.EVENTCREATOR);
		this.title = (String) eventEntity.getProperty(Constants_EventInfo.EVENTTITLE);
		this.category = (String) eventEntity.getProperty(Constants_EventInfo.EVENTCATEGORY);
		this.capacity = (long) eventEntity.getProperty(Constants_EventInfo.EVENTCAPACITY);
		this.startDateTime = (Date) eventEntity.getProperty(Constants_EventInfo.EVENTSTARTDATETIME);
		this.endDateTime = (Date) eventEntity.getProperty(Constants_EventInfo.EVENTENDDATETIME);
		this.location = (String) eventEntity.getProperty(Constants_EventInfo.EVENTLOCATION);
		this.contact = (String) eventEntity.getProperty(Constants_EventInfo.EVENTCONTACT);
		this.description = (String) eventEntity.getProperty(Constants_EventInfo.EVENTDESCRIPTION);
	}
	
	public Key getKey()
	{
		return key;
	}
	public void setKey(Key key)
	{
		this.key = key;
	}
	public String getCreator()
	{
		return creator;
	}
	public void setCreator(String creator)
	{
		this.creator = creator;
	}
	public String getTitle()
	{
		return title;
	}
	public void setTitle(String title)
	{
		this.title = title;
	}
	public String getCategory()
	{
		return category;
	}
	public void setCategory(String category)
	{
		this.category = category;
	}
	public long getCapacity()
	{
		return capacity;
	}
	public void setCapacity(long capacity)
	{
		this.capacity = capacity;
	}
	public Date getStartDateTime()
	{
		return startDateTime;
	}

	public void setStartDateTime(Date startDateTime)
	{
		this.startDateTime = startDateTime;
	}
	public Date getEndDateTime()
	{
		return endDateTime;
	}
	public void setEnd(Date endDateTime)
	{
		this.endDateTime = endDateTime;
	}
	public String getLocation()
	{
		return location;
	}
	public void setLocation(String location)
	{
		this.location = location;
	}
	public String getContact()
	{
		return contact;
	}
	public void setContact(String contact)
	{
		this.contact = contact;
	}
	public String getDescription()
	{
		return description;
	}
	public void setDescription(String description)
	{
		this.description = description;
	}
}
