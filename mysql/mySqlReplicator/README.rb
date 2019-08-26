this scripts is used to replicate mysql between two servers,
it does not require, paswordless ssh since it creates a listener.
scripts relaies on creating a LV snapshot 
when using it you need to create a listener in the target server, and then start the replication process on the source
you need to configure the base dir of the LVM where the db resides
