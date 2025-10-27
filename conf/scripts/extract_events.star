load("json.star", "json")
load("time.star", "time")
load("logging.star", "log")

def apply(metric):
    metrics = [] 
    api_data = json.decode(metric.fields["value"])

    for item in api_data["items"]:
        event=[]
        # we only return records that have events
        for k,v in item.items():
            # gather all of the common fields that are not in the events array
            if k != "events":
                event.append("{}:{}".format(k,v))
            else:
                # when there are multiple events, we want to create multiple log entries in splunk
                for event_details in item["events"]:
                    # create a new metric for each event
                    m = Metric("scc_changelog")
                    new_event = list(event)
                    new_event.append("tenant:{}".format(TENANT_NAME))
                    for key,value in event_details.items():
                        new_event.append("{}:{}".format(key,value))
                    m.fields["event"] = ", ".join(new_event)
                    metrics.append(m)
    return metrics