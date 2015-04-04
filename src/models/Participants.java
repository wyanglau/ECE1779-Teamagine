package models;

import java.io.Serializable;

import javax.persistence.*;

import com.google.appengine.api.datastore.Key;

/**
 * Entity implementation class for Entity: Participants
 *
 */
@Entity
public class Participants implements Serializable {

	private static final long serialVersionUID = 1L;

	public Participants() {
		super();
	}

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Key id;

}
