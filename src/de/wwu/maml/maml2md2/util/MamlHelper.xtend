package de.wwu.maml.maml2md2.util

import de.wwu.maml.dsl.mamldata.DataType
import de.wwu.maml.dsl.mamldata.Collection
import de.wwu.maml.dsl.mamldata.CustomType
import de.wwu.maml.dsl.mamldata.AnonymousType

class MamlHelper {
	
	static def String getDataTypeName(DataType type) {
		switch type {
			Collection: return getDataTypeName(type.type) + "Coll"
			AnonymousType: return "Anonymous" + type.hashCode
			CustomType: return type.name
			de.wwu.maml.dsl.mamldata.Enum: return type.name
			default: return null
		}
	}
}