
::Version::setSubversionId {$Id$}

snit::type ContentRoaming {
	# GetProfile, UpdateProfile,
	# CreateDocument, FindDocuments,
	# CreateRelationships, DeleteRelationships

	# url : "https://storage.msn.com/storageservice/SchematizedStore.asmx"

	variable affinity_cache ""

	method GetProfile { callbk {email ""}} {
		$::sso RequireSecurityToken Storage [list $self GetProfileSSOCB $callbk $email]
	}

	method GetProfileSSOCB { callbk email ticket} {
		set request [SOAPRequest create %AUTO% \
				 -url "https://storage.msn.com/storageservice/SchematizedStore.asmx" \
				 -action "http://www.msn.com/webservices/storage/w10/GetProfile" \
				 -header [$self getCommonHeaderXML RoamingSeed $ticket] \
				 -body [$self getGetProfileBodyXML $email] \
				 -callback [list $self GetProfileCallback $callbk $email]]
		
		$request SendSOAPRequest
		
	}


	method getGetProfileBodyXML { email } {
		if {$email == "" } {
			set cid [::abook::getPersonal cid]
		} else {
			set cid [::abook::getContactData $email cid]
		}

		# LastModified tags are set to false since we don't need those and it will
		# decrease the bandwidth used... might be set to true later if needed...
		append xml {<GetProfile xmlns="http://www.msn.com/webservices/storage/w10">}
		append xml {<profileHandle>}
		append xml {<Alias>}
		append xml {<Name>}
		append xml $cid
		append xml {</Name>}
		append xml {<NameSpace>MyCidStuff</NameSpace>}
		append xml {</Alias>}
		append xml {<RelationshipName>MyProfile</RelationshipName>}
		append xml {</profileHandle>}
		append xml {<profileAttributes>}
		append xml {<ResourceID>true</ResourceID>}
		append xml {<DateModified>true</DateModified>}
		append xml {<ExpressionProfileAttributes>}
		append xml {<ResourceID>true</ResourceID>}
		append xml {<DateModified>true</DateModified>}
		append xml {<DisplayName>true</DisplayName>}
		append xml {<DisplayNameLastModified>true</DisplayNameLastModified>}
		append xml {<PersonalStatus>true</PersonalStatus>}
		append xml {<PersonalStatusLastModified>true</PersonalStatusLastModified>}
		append xml {<StaticUserTilePublicURL>true</StaticUserTilePublicURL>}
		append xml {<Photo>true</Photo>}
		append xml {<Flags>true</Flags>}
		append xml {</ExpressionProfileAttributes>}
		append xml {</profileAttributes>}
		append xml {</GetProfile>}

		return $xml
	}
	

	method GetProfileCallback { callbk email soap } {
		set nick ""
		set last_modif ""
		set psm ""
		set dp ""
		#puts [$soap GetResponse]
		if { [$soap GetStatus] == "success" } {
			set fail 0
			set xml [$soap GetResponse]
			$self UpdateCacheKey $xml

			set result [GetXmlNode $xml "soap:Envelope:soap:Body:GetProfileResponse:GetProfileResult"]
			if {$result != "" } {
				set rid [GetXmlEntry $result "GetProfileResult:ExpressionProfile:ResourceID"]
				if {$rid != "" } {
					if {$email == "" } {
						::abook::setPersonal profile_resourceid $rid
					} else {
						::abook::setContactData $email profile_resourceid $rid
					}
					set nick [GetXmlEntry $result "GetProfileResult:ExpressionProfile:DisplayName"]
					set last_modif [GetXmlEntry $result "GetProfileResult:ExpressionProfile:DisplayNameLastModified"]
					set psm [GetXmlEntry $result "GetProfileResult:ExpressionProfile:PersonalStatus"]

					# TODO : DP is more complicated.. will look at it later...
				} else {
					set fail 4
				}
			}
			
		} elseif { [$soap GetStatus] == "fault" } { 
			set errorcode [$soap GetFaultDetail]
			if {$errorcode == "ItemDoesNotExist"} {
				set fail 3				
			} elseif {$errorcode == "InvalidObjectHandle"} {
				set fail 2
			} else {
				set fail 1				
			}
		} else {
			set fail 1
		}
		
		$soap destroy
		if {[catch {eval $callbk [list $nick $last_modif $psm $dp $fail]} result]} {
			bgerror $result
		}
	}

	method UpdateProfile { callbk nickname psm } {
		$::sso RequireSecurityToken Storage [list $self UpdateProfileSSOCB $callbk $nickname $psm]
	}

	method UpdateProfileSSOCB { callbk nickname psm ticket} {
		set rid [::abook::getPersonal profile_resourceid]
		if {$rid == "" } {
			if {[catch {eval $callbk [list -1]} result]} {
				bgerror $result
			}
		} else {
			set request [SOAPRequest create %AUTO% \
					 -url "https://storage.msn.com/storageservice/SchematizedStore.asmx" \
					 -action "http://www.msn.com/webservices/storage/w10/UpdateProfile" \
					 -header [$self getCommonHeaderXML RoamingIdentityChanged $ticket] \
					 -body [$self getUpdateProfileBodyXML $rid $nickname $psm] \
					 -callback [list $self UpdateProfileCallback $callbk]]
			
			$request SendSOAPRequest
		}
		
	}

	method getUpdateProfileBodyXML { rid nickname psm } {
		append xml {<UpdateProfile xmlns="http://www.msn.com/webservices/storage/w10">}
		append xml {<profile>}
		append xml {<ResourceID>}
		append xml [xmlencode $rid]
		append xml {</ResourceID>}
		append xml {<ExpressionProfile>}
		append xml {<FreeText>Update</FreeText>}
		append xml {<DisplayName>}
		append xml [xmlencode $nickname]
		append xml {</DisplayName>}
		append xml {<PersonalStatus>}
		append xml [xmlencode $psm]
		append xml {</PersonalStatus>}
		append xml {<Flags>0</Flags>}
		append xml {</ExpressionProfile>}
		append xml {</profile>}
		append xml {</UpdateProfile>}

		return $xml
	}

	method UpdateProfileCallback { callbk soap } {
		#puts [$soap GetResponse]
		if { [$soap GetStatus] == "success" } {
			set fail 0
			$self UpdateCacheKey [$soap GetResponse]
		} elseif { [$soap GetStatus] == "fault" } { 
			set errorcode [$soap GetFaultDetail]
			if {$errorcode == "AccessDenied" } {
				set fail 2
			} else {
				set fail 1				
			}
		} else {
			set fail 1
		}
		
		$soap destroy
		if {[catch {eval $callbk [list $fail]} result]} {
			bgerror $result
		}
	}


	method CreateProfile { callbk } {
		$::sso RequireSecurityToken Storage [list $self CreateProfileSSOCB $callbk]
	}

	method CreateProfileSSOCB { callbk ticket} {
		set request [SOAPRequest create %AUTO% \
				 -url "https://storage.msn.com/storageservice/SchematizedStore.asmx" \
				 -action "http://www.msn.com/webservices/storage/w10/CreateProfile" \
				 -header [$self getCommonHeaderXML RoamingSeed $ticket] \
				 -body [$self getCreateProfileBodyXML] \
				 -callback [list $self CreateProfileCallback $callbk]]
		
		$request SendSOAPRequest
		
	}


	method getCreateProfileBodyXML { } {
		append xml {<CreateProfile xmlns="http://www.msn.com/webservices/storage/w10">}
		append xml {<profile>}
		append xml {<ExpressionProfile>}
		append xml {<PersonalStatus/>}
		append xml {<RoleDefinitionName>ExpressionProfileDefault</RoleDefinitionName>}
		append xml {</ExpressionProfile>}
		append xml {</profile>}
		append xml {</CreateProfile>}

		return $xml
	}
	
	method CreateProfileCallback { callbk soap } {
		set rid ""
		#puts [$soap GetResponse]
		if { [$soap GetStatus] == "success" } {
			set fail 0
			set xml [$soap GetResponse]
			$self UpdateCacheKey $xml
			set rid [GetXmlEntry $xml "soap:Envelope:soap:Body:CreateProfileResponse:CreateProfileResult"]	
			if {$rid != "" } {
				::abook::setPersonal profile_resourceid $rid
			}
		} elseif { [$soap GetStatus] == "fault" } { 
			set errorcode [$soap GetFaultDetail]
			if {$errorcode == "ItemAlreadyExists"} {
				set fail 2
			} else {
				set fail 1
			}
		} else {
			set fail 1
		}
		
		$soap destroy
		if {[catch {eval $callbk [list $rid $fail]} result]} {
			bgerror $result
		}
	}

	method ShareItem { callbk rid } {
		$::sso RequireSecurityToken Storage [list $self ShareItemSSOCB $callbk $rid]
	}

	method ShareItemSSOCB { callbk rid ticket} {
		set request [SOAPRequest create %AUTO% \
				 -url "https://storage.msn.com/storageservice/SchematizedStore.asmx" \
				 -action "http://www.msn.com/webservices/storage/w10/ShareItem" \
				 -header [$self getCommonHeaderXML RoamingSeed $ticket] \
				 -body [$self getShareItemBodyXML $rid] \
				 -callback [list $self ShareItemCallback $callbk]]
		
		$request SendSOAPRequest
		
	}


	method getShareItemBodyXML { rid } {
		append xml {<ShareItem xmlns="http://www.msn.com/webservices/storage/w10">}
		append xml {<resourceID>}
		append xml [xmlencode $rid]
		append xml {</resourceID>}
		append xml {<displayName>Messenger Roaming Identity</displayName>}
		append xml {</ShareItem>}

		return $xml
	}
	
	method ShareItemCallback { callbk soap } {
		#puts [$soap GetResponse]
		if { [$soap GetStatus] == "success" } {
			set fail 0
			$self UpdateCacheKey [$soap GetResponse]
		} else {
			set fail 1
		}
		
		$soap destroy
		if {[catch {eval $callbk [list $fail]} result]} {
			bgerror $result
		}
	}


	method FindDocuments { callbk } {
		$::sso RequireSecurityToken Storage [list $self FindDocumentsSSOCB $callbk]
	}

	method FindDocumentsSSOCB { callbk ticket} {
		set request [SOAPRequest create %AUTO% \
				 -url "https://storage.msn.com/storageservice/SchematizedStore.asmx" \
				 -action "http://www.msn.com/webservices/storage/w10/FindDocuments" \
				 -header [$self getCommonHeaderXML RoamingIdentityChanged $ticket] \
				 -body [$self getFindDocumentsBodyXML] \
				 -callback [list $self FindDocumentsCallback $callbk]]
		
		$request SendSOAPRequest
	}

	method getFindDocumentsBodyXML { } {
		set cid [::abook::getPersonal cid]

		append xml {<FindDocuments xmlns="http://www.msn.com/webservices/storage/w10">}
		append xml {<objectHandle>}
		append xml {<RelationshipName>/UserTiles</RelationshipName>}
		append xml {<Alias>}
		append xml {<Name>}
		append xml [xmlencode $cid]
		append xml {</Name>}
		append xml {<NameSpace>MyCidStuff</NameSpace>}
		append xml {</Alias>}
		append xml {</objectHandle>}
		append xml {<documentAttributes>}
		append xml {<ResourceID>true</ResourceID>}
		append xml {<Name>true</Name>}
		append xml {</documentAttributes>}
		append xml {<documentFilter>}
		append xml {<FilterAttributes>None</FilterAttributes>}
		append xml {</documentFilter>}
		append xml {<documentSort>}
		append xml {<SortBy>DateModified</SortBy>}
		append xml {</documentSort>}
		append xml {<findContext>}
		append xml {<FindMethod>Default</FindMethod>}
		append xml {<ChunkSize>25</ChunkSize>}
		append xml {</findContext>}
		append xml {</FindDocuments>}

		return $xml
	}

	method FindDocumentsCallback { callbk soap } {
		#puts [$soap GetResponse]
		if { [$soap GetStatus] == "success" } {
			set fail 0

			set xml [$soap GetResponse]
			$self UpdateCacheKey $xml
			set documents [list]
			set i 0
			while {1} {
				set subxml [GetXmlNode $xml "soap:Envelope:soap:Body:FindDocumentsResponse:FindDocumentsResult:Document" $i]
				incr i
				if  { $subxml == "" } {
					break
				}
				set rid [GetXmlEntry $subxml "Document:ResourceID"]
				set name [GetXmlEntry $subxml "Document:Name"]
				lappend documents [list $rid $name]
			}
			
		} else {
			set documents [list]
		}
		
		$soap destroy
		if {[catch {eval $callbk [list $documents]} result]} {
			bgerror $result
		}
	}

	method UpdateCacheKey { xml } {
		set cache [GetXmlEntry $xml "soap:Envelope:soap:Header:AffinityCacheHeader:CacheKey"]
		if {$cache != "" } {
			set affinity_cache $cache
		}
	}

	method getCommonHeaderXML { scenario ticket } {
		if {$affinity_cache != "" } {
			append xml {<AffinityCacheHeader xmlns="http://www.msn.com/webservices/storage/w10">}
			append xml {<CacheKey>}
			append xml [xmlencode $affinity_cache]
			append xml {</CacheKey>}
			append xml {</AffinityCacheHeader>}
		}

		append xml {<StorageApplicationHeader xmlns="http://www.msn.com/webservices/storage/w10">}
		append xml {<ApplicationID>Messenger Client 8.5</ApplicationID>}
		append xml {<Scenario>}
		append xml $scenario
		append xml {</Scenario>}
		append xml {</StorageApplicationHeader>}

		append xml {<StorageUserHeader xmlns="http://www.msn.com/webservices/storage/w10">}
		append xml {<Puid>0</Puid>}
		append xml {<TicketToken>}
		append xml [xmlencode $ticket]
		append xml {</TicketToken>}
		append xml {</StorageUserHeader>}
		
		return $xml

	}
}
