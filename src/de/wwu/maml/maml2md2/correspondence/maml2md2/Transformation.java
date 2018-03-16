/**
 */
package de.wwu.maml.maml2md2.correspondence.maml2md2;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Transformation</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link de.wwu.maml.maml2md2.correspondence.maml2md2.Transformation#getCorrespondences <em>Correspondences</em>}</li>
 * </ul>
 *
 * @see de.wwu.maml.maml2md2.correspondence.maml2md2.Maml2md2Package#getTransformation()
 * @model
 * @generated
 */
public interface Transformation extends EObject {
	/**
	 * Returns the value of the '<em><b>Correspondences</b></em>' containment reference list.
	 * The list contents are of type {@link de.wwu.maml.maml2md2.correspondence.maml2md2.Corr}.
	 * <!-- begin-user-doc -->
	 * <p>
	 * If the meaning of the '<em>Correspondences</em>' containment reference list isn't clear,
	 * there really should be more of a description here...
	 * </p>
	 * <!-- end-user-doc -->
	 * @return the value of the '<em>Correspondences</em>' containment reference list.
	 * @see de.wwu.maml.maml2md2.correspondence.maml2md2.Maml2md2Package#getTransformation_Correspondences()
	 * @model containment="true"
	 * @generated
	 */
	EList<Corr> getCorrespondences();

} // Transformation
