package DAO;

import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;

public class DatastoreWriter {
	
	public DatastoreWriter ()
	{
	}
	
	public Key writeToDatastoreAndRetrieveKey (Entity givenEntity)
	{
		return DatastoreServiceFactory.getDatastoreService().put(givenEntity);
	}
}
