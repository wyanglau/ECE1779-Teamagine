package models;

import java.io.Serializable;
import java.util.List;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;

import DAO.Constants_EventInfo;
import DAO.Constants_EventPeeps;

public class Peeps implements Serializable {

	private static final long serialVersionUID = 1L;

	private long id;

	private List<String> peeps;

	public Peeps fromEntityAndKey(long id, Entity eventEntity) {
		this.id = id;
		this.peeps = (List<String>) eventEntity
				.getProperty(Constants_EventPeeps.EVENTMEMBERS);
		return this;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public List<String> getPeeps() {
		return peeps;
	}

	public void setPeeps(List<String> peeps) {
		this.peeps = peeps;
	}
}
