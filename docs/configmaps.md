# Configuration Maps

## Introduction

Configuration Maps (aka _config maps_) are an unique VA Artifact to precisely define which Applications and prerequisites (other Configuration Maps) are going to be loaded as a whole, providing a reliable dependency management solution.

Unfortunately, Tonel doesn't define any similar artifact nor _type_ that we could leverage to provide similar features.

## Solution

In order to provide an artifact that is human readable (and friendly with a file based source control system) all configuration maps will be written to a single `.configmaps` file in STON syntax along Tonel's `.properties` file in the sources directory. So if you choose to write more than one config map, all of them will be written to that single file.

The rationale to have a single file instead of several ones is that config maps can have names with spaces or other special characters (`/`, `#`, etc.) that would require special handling on the filesystem. 

## Writing Configuration Maps to disk

The `TonelWriter` in addition to the list of Applications that will be written as Tonel packages, has a separate list of configuration maps, where **only one version of each config map is allowed**, each configuration map must be an instance of _EmConfigurationMap_.

You can add a config map to the writer as follows
```smalltalk
writer := TonelWriter new.
writer addConfigurationMap: (EmConfigurationMap editionsFor: 'Tonel') first.
```
Or
```smalltalk
writer := TonelWriter new.
writer addConfigurationMapNamed: 'Tonel' versionName: '1.40'.
```

The addition of a config map to the _writer_ is separate from the addition of its applications, but to avoid having to lookup each app you could send `#addApplicationsFromConfigurationMaps` to the writer, which will lookup all the applications in the config map, and add them to the writer.

```smalltalk
writer := TonelWriter new.
writer addConfigurationMapNamed: 'Tonel' versionName: '1.40'.
writer addApplicationsFromConfigurationMaps.
```

This will produce the a `.configmaps` file with the following STON content:

```smalltalk
[
	{
		#name : 'Tonel',
		#versionName : '1.43',
		#comment : '',
		#applications : [
			'TonelBaseApp' : '1.0',
			'TonelFileSystem' : '1.23',
			'TonelLoaderModel' : '1.48',
			'TonelLoaderTests' : '1.5',
			'TonelReaderModel' : '1.49',
			'TonelReaderTests' : '1.30',
			'TonelTools' : '1.10',
			'TonelWriterModel' : '1.47',
			'TonelWriterTests' : '1.31'
		],
		#conditions : [
			{
				#condition : 'true',
				#requiredMaps : [
					'z.ST: SUnit' : 'V 9.2.0  [453]',
					'z.ST: STON Support' : 'V 9.2.0  [453]'
				]
			}
		]
	}
]
```

### Autoloading

If you attempt to write a Configuration Map that isn't loaded in the image, by default `TonelWriter` will attempt to load it first (and its required maps).

If you want to disable this behavior, you can do it by evaluating:
```smalltalk
aTonelWriter autoLoad: false
```

With the autoloading disabled, if you attempt to write a Configuration Map, an exception will be raised.


## Loading Configuration Maps from disk

The load of configuration maps from disk is straighfoward.

Following the above written config map you should only send `#loadAllMapsWithRequiredMaps` to the _TonelLoader_ and it will automatically load the applications and required maps.

```smalltalk
loader := TonelLoader readFromPath:  ((CfsPath named: CfsDirectoryDescriptor getcwd) append: 'tonel-vast').
loader beUnattended; useSpecifiedVersion: '1.40'.
loader loadAllMapsWithRequiredMaps.
```

### How dependency lookup is performed

When loading a Configuration Map the _TonelLoader_ will first search for any matching version in the Tonel repository and if not found then it will search it up in the ENVY Library. If no version is found in neither of these, and error will be thrown.

All applications of the Configuration Map read from disk are expected to be in the Tonel repository as well, so there is currently no way to load just the configuration map from disk and the applications from the EM Library.